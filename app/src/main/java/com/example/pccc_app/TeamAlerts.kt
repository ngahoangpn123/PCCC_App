package com.example.pccc_app

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
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
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.pccc_app.ui.theme.PcccColors

// ---------- Mô hình cảnh báo ----------
enum class AlertPriority(val label: String) {
    HIGH("Cần xử lý ngay"),
    NORMAL("Cần theo dõi")
}

// 5 loại cảnh báo theo APP_PCCC.md (mục 2.C)
enum class AlertKind(val label: String) {
    UNDERSTAFFED("Thiếu người"),
    UNCONFIRMED("Chưa xác nhận"),
    ABSENT("Vắng mặt"),
    CONFLICT("Trùng lịch"),
    MEMBER_INFO("Cần cập nhật hồ sơ"),
    MEMBER_TRAINING("Chưa đủ huấn luyện")
}

// Một thẻ = một đối tượng cần xử lý (một ca hoặc một thành viên)
data class TeamAlert(
    val id: String,
    val priority: AlertPriority,
    val title: String,
    val subtitle: String,
    val issues: List<String>,
    val shiftDay: Int? = null,      // mở tab Lịch trực ở ngày này
    val memberId: String? = null    // mở hồ sơ thành viên này
)

// Vấn đề của một thành viên (dùng cho nhãn trên thẻ thành viên và bảng cảnh báo)
// TODO: khi nối dữ liệu thật, thay điều kiện chữ bằng trường dữ liệu riêng
fun memberIssues(m: TeamMember): List<AlertKind> {
    val result = mutableListOf<AlertKind>()
    val inTeam = m.status == MemberStatus.ACTIVE || m.status == MemberStatus.ROLE_CHANGED
    if (inTeam && (m.training.isEmpty() || m.training.any { it.contains("Cần bổ sung") })) {
        result += AlertKind.MEMBER_TRAINING
    }
    if (m.status == MemberStatus.ROLE_CHANGED) result += AlertKind.MEMBER_INFO
    return result
}

// ---------- Nhãn trên thẻ thành viên ----------
@Composable
fun IssueTag(kind: AlertKind) {
    Text(
        kind.label,
        style = MaterialTheme.typography.labelSmall,
        color = PcccColors.Burgundy,
        modifier = Modifier
            .background(PcccColors.BurgundySoft, RoundedCornerShape(6.dp))
            .padding(horizontal = 6.dp, vertical = 2.dp)
    )
}

// ---------- Dải tóm tắt dưới thanh tab ----------
@Composable
fun AlertStrip(alerts: List<TeamAlert>, onClick: () -> Unit) {
    val high = alerts.count { it.priority == AlertPriority.HIGH }
    val hasAny = alerts.isNotEmpty()
    val bg = if (high > 0) PcccColors.BurgundySoft else PcccColors.BronzeSoft
    val fg = if (high > 0) PcccColors.Burgundy else Color(0xFF8A6422)

    Row(
        Modifier
            .fillMaxWidth()
            .background(bg)
            .then(if (hasAny) Modifier.clickable(onClick = onClick) else Modifier)
            .padding(horizontal = 16.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            if (hasAny) Icons.Default.Warning else Icons.Default.CheckCircle,
            contentDescription = null,
            tint = fg,
            modifier = Modifier.size(20.dp)
        )
        Spacer(Modifier.width(10.dp))
        Column(Modifier.weight(1f)) {
            Text(
                if (hasAny) "${alerts.size} việc cần xử lý" else "Không có việc cần xử lý",
                fontWeight = FontWeight.Bold,
                color = fg
            )
            if (hasAny) {
                Text(
                    if (high > 0) "$high việc cần xử lý ngay" else "Chưa có việc khẩn",
                    style = MaterialTheme.typography.bodySmall,
                    color = PcccColors.TextSecondary
                )
            }
        }
        if (hasAny) {
            Text("Xem", color = fg, fontWeight = FontWeight.SemiBold)
            Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = fg)
        }
    }
}

// ---------- Bảng danh sách cảnh báo ----------
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlertSheet(
    alerts: List<TeamAlert>,
    onDismiss: () -> Unit,
    onOpen: (TeamAlert) -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = Color.White
    ) {
        LazyColumn(
            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 32.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            item {
                Column {
                    Text(
                        "Việc cần xử lý trong đội",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        color = PcccColors.Burgundy
                    )
                    Text(
                        "Cảnh báo tự đóng khi vấn đề được xử lý, không cần xóa thủ công.",
                        style = MaterialTheme.typography.bodySmall,
                        color = PcccColors.TextSecondary
                    )
                }
            }
            AlertPriority.entries.forEach { priority ->
                val group = alerts.filter { it.priority == priority }
                if (group.isNotEmpty()) {
                    item(key = "header-${priority.name}") {
                        Text(
                            "${priority.label} (${group.size})",
                            fontWeight = FontWeight.Bold,
                            color = if (priority == AlertPriority.HIGH) PcccColors.Burgundy
                            else PcccColors.Bronze,
                            modifier = Modifier.padding(top = 6.dp)
                        )
                    }
                    items(group, key = { it.id }) { AlertCard(it, onOpen) }
                }
            }
        }
    }
}

@Composable
private fun AlertCard(alert: TeamAlert, onOpen: (TeamAlert) -> Unit) {
    val accent = if (alert.priority == AlertPriority.HIGH) PcccColors.Burgundy else PcccColors.Bronze

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, PcccColors.Outline)
    ) {
        Row(Modifier.height(IntrinsicSize.Min)) {
            Box(
                Modifier
                    .width(5.dp)
                    .fillMaxHeight()
                    .background(accent)
            )
            Column(
                Modifier
                    .weight(1f)
                    .padding(14.dp)
            ) {
                Text(alert.title, fontWeight = FontWeight.Bold, color = PcccColors.TextPrimary)
                Text(
                    alert.subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = PcccColors.TextSecondary
                )
                Spacer(Modifier.height(8.dp))
                alert.issues.forEach { issue ->
                    Row(Modifier.padding(vertical = 2.dp), verticalAlignment = Alignment.Top) {
                        Box(
                            Modifier
                                .padding(top = 7.dp)
                                .size(6.dp)
                                .background(accent, CircleShape)
                        )
                        Spacer(Modifier.width(8.dp))
                        Text(
                            issue,
                            style = MaterialTheme.typography.bodyMedium,
                            color = PcccColors.TextPrimary
                        )
                    }
                }
                Spacer(Modifier.height(10.dp))
                OutlinedButton(
                    onClick = { onOpen(alert) },
                    border = BorderStroke(1.dp, accent)
                ) {
                    Text(
                        if (alert.shiftDay != null) "Xem ca trực" else "Xem hồ sơ",
                        color = accent
                    )
                }
            }
        }
    }
}