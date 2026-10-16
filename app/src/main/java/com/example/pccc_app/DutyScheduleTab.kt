package com.example.pccc_app

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.pccc_app.ui.theme.PcccColors

// ---------- Dữ liệu mẫu tĩnh ----------
private enum class ShiftStatus(val label: String) {
    PLANNED("Dự kiến"),
    CONFIRMED("Đã xác nhận"),
    ON_DUTY("Đang trực"),
    DONE("Đã hoàn thành")
}

private data class DutyShift(
    val id: String,
    val dayIndex: Int,          // 0 = T2 ... 6 = CN
    val startHour: Int,
    val endHour: Int,
    val location: String,
    val required: Int,          // quân số cần có (do cơ sở thiết lập)
    val memberIds: List<String>,
    val confirmedIds: List<String>,
    val leaderId: String?,
    val status: ShiftStatus,
    val absentNote: String? = null,
    val handoverNote: String? = null,
    val issueNote: String? = null
)

// Tuần mẫu 12/10 – 18/10/2026
private val weekDays = listOf(
    "T2" to "12/10", "T3" to "13/10", "T4" to "14/10", "T5" to "15/10",
    "T6" to "16/10", "T7" to "17/10", "CN" to "18/10"
)
const val TODAY_INDEX = 4

private val sampleShifts = listOf(
    DutyShift(
        "s1", 0, 7, 15, "Cổng chính", 2,
        listOf("m1", "m3"), listOf("m1", "m3"), "m1", ShiftStatus.DONE
    ),
    DutyShift(
        "s2", 2, 7, 15, "Cổng chính", 2,
        listOf("m2", "m3"), listOf("m2", "m3"), "m2", ShiftStatus.DONE,
        handoverNote = "Đã kiểm tra bình chữa cháy khu A."
    ),
    DutyShift(
        "s3", 4, 7, 15, "Cổng chính", 2,
        listOf("m1", "m3"), listOf("m1", "m3"), "m1", ShiftStatus.ON_DUTY,
        handoverNote = "Bàn giao ca sáng: khu A bình thường."
    ),
    DutyShift(
        "s4", 4, 15, 23, "Khu nhà xưởng", 3,
        listOf("m2", "m5"), listOf("m2"), "m2", ShiftStatus.PLANNED
    ),
    DutyShift(
        "s5", 5, 7, 15, "Cổng chính", 2,
        listOf("m4", "m3"), listOf("m3"), "m3", ShiftStatus.PLANNED,
        absentNote = "Phạm Thị D (tạm vắng), chưa có người thay",
        issueNote = "Cần bố trí người thay thế."
    ),
    DutyShift(
        "s6", 5, 9, 17, "Kho hàng", 1,
        listOf("m3"), listOf("m3"), "m3", ShiftStatus.CONFIRMED
    ),
    DutyShift(
        "s7", 6, 7, 15, "Cổng chính", 2,
        emptyList(), emptyList(), null, ShiftStatus.PLANNED
    )
)

private fun memberOf(id: String): TeamMember? = sampleMembers.firstOrNull { it.id == id }

private fun timeText(s: DutyShift) = "%02d:00 – %02d:00".format(s.startHour, s.endHour)

// Cảnh báo tự tính từ dữ liệu ca (theo mục 2.C và phần UX của tài liệu)
// Vấn đề của một ca trực, tính từ dữ liệu ca (nguồn chung cho thẻ ca và bảng cảnh báo)
private fun shiftIssues(shift: DutyShift, all: List<DutyShift>): List<Pair<AlertKind, String>> {
    if (shift.status == ShiftStatus.DONE) return emptyList()
    val result = mutableListOf<Pair<AlertKind, String>>()
    if (shift.memberIds.size < shift.required) {
        result += AlertKind.UNDERSTAFFED to
                "Thiếu người: ${shift.memberIds.size}/${shift.required} đã phân công"
    }
    val pending = shift.memberIds.size - shift.confirmedIds.size
    if (pending > 0) result += AlertKind.UNCONFIRMED to "$pending thành viên chưa xác nhận"
    shift.absentNote?.let { result += AlertKind.ABSENT to "Vắng mặt: $it" }
    val conflicts = shift.memberIds.filter { id ->
        all.any { o ->
            o.id != shift.id && o.dayIndex == shift.dayIndex && id in o.memberIds &&
                    shift.startHour < o.endHour && o.startHour < shift.endHour
        }
    }
    if (conflicts.isNotEmpty()) {
        result += AlertKind.CONFLICT to
                "Trùng lịch: " + conflicts.joinToString { memberOf(it)?.name ?: it }
    }
    return result
}

private fun warningsOf(shift: DutyShift, all: List<DutyShift>): List<String> =
    shiftIssues(shift, all).map { it.second }

// Bộ máy phát cảnh báo cho cả đội: mỗi ca hoặc mỗi thành viên là một thẻ
fun buildTeamAlerts(): List<TeamAlert> {
    val alerts = mutableListOf<TeamAlert>()
    val seenConflicts = mutableSetOf<String>()

    for (shift in sampleShifts) {
        val daysUntil = shift.dayIndex - TODAY_INDEX
        if (daysUntil < 0) continue
        val issues = shiftIssues(shift, sampleShifts).filter { (kind, text) ->
            // một vụ trùng lịch ảnh hưởng hai ca nhưng chỉ báo một lần
            kind != AlertKind.CONFLICT || seenConflicts.add("${shift.dayIndex}|$text")
        }
        if (issues.isEmpty()) continue
        val urgent = issues.any { (kind, _) ->
            if (kind == AlertKind.UNCONFIRMED) daysUntil == 0 else daysUntil <= 1
        }
        val (dayName, date) = weekDays[shift.dayIndex]
        alerts += TeamAlert(
            id = shift.id,
            priority = if (urgent) AlertPriority.HIGH else AlertPriority.NORMAL,
            title = "$dayName $date · ${timeText(shift)}",
            subtitle = "Ca trực · ${shift.location}",
            issues = issues.map { it.second },
            shiftDay = shift.dayIndex
        )
    }

    for (m in sampleMembers) {
        val issues = memberIssues(m).map { kind ->
            when (kind) {
                AlertKind.MEMBER_TRAINING -> "Chưa đủ huấn luyện theo yêu cầu áp dụng"
                else -> "Đã đổi nhiệm vụ, cần cập nhật phân công và hồ sơ"
            }
        }
        if (issues.isEmpty()) continue
        alerts += TeamAlert(
            id = m.id,
            priority = AlertPriority.NORMAL,
            title = m.name,
            subtitle = "Thành viên · ${m.code}",
            issues = issues,
            memberId = m.id
        )
    }

    return alerts.sortedWith(compareBy({ it.priority.ordinal }, { it.shiftDay ?: 99 }))
}

// ---------- Màn hình tab ----------
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DutyScheduleTab(selectedDay: Int, onDayChange: (Int) -> Unit) {
    var mode by remember { mutableIntStateOf(0) }            // 0 = lịch tuần, 1 = danh sách ca
    var openedMember by remember { mutableStateOf<TeamMember?>(null) }

    val chipColors = FilterChipDefaults.filterChipColors(
        selectedContainerColor = PcccColors.Burgundy,
        selectedLabelColor = Color.White
    )

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(PcccColors.Background),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Column {
                Button(
                    onClick = { /* TODO: màn hình tạo lịch trực */ },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(14.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = PcccColors.Burgundy)
                ) {
                    Icon(Icons.Default.Add, contentDescription = null)
                    Spacer(Modifier.width(8.dp))
                    Text("Tạo lịch trực", fontWeight = FontWeight.Bold)
                }
                Spacer(Modifier.height(6.dp))
                Text(
                    "Quân số yêu cầu do cơ sở thiết lập theo quy định và đặc điểm của cơ sở.",
                    style = MaterialTheme.typography.bodySmall,
                    color = PcccColors.TextSecondary
                )
            }
        }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                FilterChip(
                    selected = mode == 0,
                    onClick = { mode = 0 },
                    label = { Text("Lịch tuần") },
                    colors = chipColors
                )
                FilterChip(
                    selected = mode == 1,
                    onClick = { mode = 1 },
                    label = { Text("Danh sách ca") },
                    colors = chipColors
                )
            }
        }

        if (mode == 0) {
            item {
                WeekStrip(selectedDay = selectedDay, onSelect = onDayChange)
            }
            val dayShifts = sampleShifts.filter { it.dayIndex == selectedDay }
            if (dayShifts.isEmpty()) {
                item {
                    Text(
                        "Không có ca trực trong ngày này",
                        color = PcccColors.TextSecondary,
                        modifier = Modifier.padding(vertical = 24.dp)
                    )
                }
            } else {
                items(dayShifts, key = { it.id }) { shift ->
                    ShiftCard(shift, warningsOf(shift, sampleShifts)) { openedMember = it }
                }
            }
        } else {
            for (day in weekDays.indices) {
                val dayShifts = sampleShifts.filter { it.dayIndex == day }
                if (dayShifts.isEmpty()) continue
                item(key = "header$day") {
                    Text(
                        "${weekDays[day].first} · ${weekDays[day].second}",
                        fontWeight = FontWeight.Bold,
                        color = PcccColors.Burgundy,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
                items(dayShifts, key = { it.id }) { shift ->
                    ShiftCard(shift, warningsOf(shift, sampleShifts)) { openedMember = it }
                }
            }
        }
    }

    openedMember?.let { member ->
        MemberDetailSheet(member, onDismiss = { openedMember = null })
    }
}

// ---------- Thanh 7 ngày ----------
@Composable
private fun WeekStrip(selectedDay: Int, onSelect: (Int) -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, PcccColors.Outline)
    ) {
        Column(Modifier.padding(12.dp)) {
            Text(
                "Tuần 12/10 – 18/10/2026",
                style = MaterialTheme.typography.labelMedium,
                color = PcccColors.TextSecondary
            )
            Spacer(Modifier.height(8.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                weekDays.forEachIndexed { index, (label, date) ->
                    val dayShifts = sampleShifts.filter { it.dayIndex == index }
                    val hasWarning = dayShifts.any { warningsOf(it, sampleShifts).isNotEmpty() }
                    val isSelected = index == selectedDay
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(12.dp))
                            .background(if (isSelected) PcccColors.Burgundy else Color.Transparent)
                            .clickable { onSelect(index) }
                            .padding(vertical = 8.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            label,
                            style = MaterialTheme.typography.labelSmall,
                            color = if (isSelected) Color.White else PcccColors.TextSecondary
                        )
                        Text(
                            date.substringBefore("/"),
                            fontWeight = FontWeight.Bold,
                            color = if (isSelected) Color.White else PcccColors.TextPrimary
                        )
                        Spacer(Modifier.height(4.dp))
                        Box(
                            Modifier
                                .size(6.dp)
                                .background(
                                    when {
                                        dayShifts.isEmpty() -> Color.Transparent
                                        hasWarning -> if (isSelected) Color.White else PcccColors.Burgundy
                                        else -> PcccColors.Bronze
                                    },
                                    CircleShape
                                )
                        )
                    }
                }
            }
        }
    }
}

// ---------- Thẻ ca trực ----------
@Composable
private fun ShiftCard(
    shift: DutyShift,
    warnings: List<String>,
    onMemberClick: (TeamMember) -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, PcccColors.Outline)
    ) {
        Column(Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.weight(1f)) {
                    Text(
                        timeText(shift),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = PcccColors.TextPrimary
                    )
                    Text(
                        "Địa điểm: ${shift.location}",
                        style = MaterialTheme.typography.bodySmall,
                        color = PcccColors.TextSecondary
                    )
                }
                ShiftStatusChip(shift.status)
            }

            Spacer(Modifier.height(10.dp))
            HeadcountBar(shift)

            if (warnings.isNotEmpty()) {
                Spacer(Modifier.height(10.dp))
                Column(
                    Modifier
                        .fillMaxWidth()
                        .background(PcccColors.BurgundySoft, RoundedCornerShape(12.dp))
                        .padding(10.dp)
                ) {
                    warnings.forEach { text ->
                        Row(Modifier.padding(vertical = 2.dp), verticalAlignment = Alignment.Top) {
                            Icon(
                                Icons.Default.Warning,
                                contentDescription = null,
                                tint = PcccColors.Burgundy,
                                modifier = Modifier
                                    .padding(top = 2.dp)
                                    .size(14.dp)
                            )
                            Spacer(Modifier.width(6.dp))
                            Text(
                                text,
                                style = MaterialTheme.typography.bodySmall,
                                color = PcccColors.Burgundy
                            )
                        }
                    }
                }
            }

            Spacer(Modifier.height(10.dp))
            HorizontalDivider(color = PcccColors.Outline)
            Text(
                "Thành viên được phân công",
                style = MaterialTheme.typography.labelMedium,
                color = PcccColors.TextSecondary,
                modifier = Modifier.padding(top = 8.dp)
            )
            if (shift.memberIds.isEmpty()) {
                Text(
                    "Chưa phân công thành viên nào",
                    style = MaterialTheme.typography.bodyMedium,
                    color = PcccColors.Burgundy,
                    modifier = Modifier.padding(vertical = 6.dp)
                )
            } else {
                shift.memberIds.forEach { id ->
                    val member = memberOf(id)
                    if (member != null) {
                        MemberLine(
                            member = member,
                            isLeader = id == shift.leaderId,
                            confirmed = id in shift.confirmedIds,
                            onClick = { onMemberClick(member) }
                        )
                    }
                }
            }

            shift.handoverNote?.let { NoteLine("Ghi chú bàn giao ca", it) }
            shift.issueNote?.let { NoteLine("Vấn đề phát sinh", it) }
        }
    }
}

@Composable
private fun HeadcountBar(shift: DutyShift) {
    val fraction = if (shift.required == 0) 0f
    else (shift.confirmedIds.size.toFloat() / shift.required).coerceIn(0f, 1f)

    Column {
        Text(
            "Quân số: cần ${shift.required} · phân công ${shift.memberIds.size} · " +
                    "xác nhận ${shift.confirmedIds.size}",
            style = MaterialTheme.typography.bodySmall,
            color = PcccColors.TextPrimary
        )
        Spacer(Modifier.height(6.dp))
        Box(
            Modifier
                .fillMaxWidth()
                .height(6.dp)
                .background(PcccColors.BronzeSoft, RoundedCornerShape(3.dp))
        ) {
            Box(
                Modifier
                    .fillMaxWidth(fraction)
                    .height(6.dp)
                    .background(PcccColors.Bronze, RoundedCornerShape(3.dp))
            )
        }
    }
}

@Composable
private fun MemberLine(
    member: TeamMember,
    isLeader: Boolean,
    confirmed: Boolean,
    onClick: () -> Unit
) {
    Row(
        Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(10.dp))
            .clickable(onClick = onClick)
            .padding(vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            Modifier
                .size(32.dp)
                .background(PcccColors.BurgundySoft, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Text(
                member.name.trim().takeLast(1).uppercase(),
                color = PcccColors.Burgundy,
                fontWeight = FontWeight.Bold
            )
        }
        Spacer(Modifier.width(10.dp))
        Column(Modifier.weight(1f)) {
            Text(member.name, fontWeight = FontWeight.SemiBold, color = PcccColors.TextPrimary)
            Text(
                if (isLeader) "${member.role} · Người phụ trách ca" else member.role,
                style = MaterialTheme.typography.bodySmall,
                color = if (isLeader) PcccColors.Bronze else PcccColors.TextSecondary
            )
        }
        if (confirmed) {
            Icon(
                Icons.Default.CheckCircle,
                contentDescription = "Đã xác nhận",
                tint = PcccColors.Burgundy,
                modifier = Modifier.size(20.dp)
            )
        } else {
            Text(
                "Chờ xác nhận",
                style = MaterialTheme.typography.labelSmall,
                color = Color(0xFF8A6422)
            )
        }
    }
}

@Composable
private fun NoteLine(label: String, text: String) {
    Column(Modifier.padding(top = 8.dp)) {
        Text(label, style = MaterialTheme.typography.labelMedium, color = PcccColors.TextSecondary)
        Text(text, style = MaterialTheme.typography.bodyMedium, color = PcccColors.TextPrimary)
    }
}

@Composable
private fun ShiftStatusChip(status: ShiftStatus) {
    val (bg, fg) = when (status) {
        ShiftStatus.PLANNED -> PcccColors.BronzeSoft to Color(0xFF8A6422)
        ShiftStatus.CONFIRMED -> PcccColors.BurgundySoft to PcccColors.Burgundy
        ShiftStatus.ON_DUTY -> PcccColors.Burgundy to Color.White
        ShiftStatus.DONE -> Color(0xFFF1EDEA) to PcccColors.TextSecondary
    }
    Text(
        status.label,
        color = fg,
        style = MaterialTheme.typography.labelMedium,
        fontWeight = FontWeight.SemiBold,
        modifier = Modifier
            .background(bg, RoundedCornerShape(50))
            .padding(horizontal = 10.dp, vertical = 4.dp)
    )
}