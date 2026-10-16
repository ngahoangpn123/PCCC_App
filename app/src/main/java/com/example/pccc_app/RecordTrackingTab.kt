package com.example.pccc_app

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.pccc_app.ui.theme.PcccColors

// ---------- Dữ liệu mẫu tĩnh ----------
private enum class RecordGroup(val label: String) {
    MISSING("Còn thiếu"),
    DUE_SOON("Sắp đến hạn"),
    IN_PROGRESS("Đang xử lý"),
    SUBMITTED("Đã nộp"),
    NEED_MORE("Cần bổ sung"),
    ACCEPTED("Đã chấp thuận")
}

private data class FormRecord(
    val code: String,
    val name: String,
    val owner: String,
    val updatedAt: String,
    val dueDate: String,
    val attachments: Int,
    val status: FormStatus,
    val group: RecordGroup,
    val history: List<String>
)

private fun record(
    code: String,
    status: FormStatus,
    group: RecordGroup,
    owner: String,
    updatedAt: String,
    dueDate: String,
    attachments: Int,
    history: List<String>
) = FormRecord(
    code = code,
    name = "Tên biểu mẫu $code (cập nhật sau)",
    owner = owner,
    updatedAt = updatedAt,
    dueDate = dueDate,
    attachments = attachments,
    status = status,
    group = group,
    history = history
)

private val sampleRecords = listOf(
    record(
        "PC01", FormStatus.NOT_CREATED, RecordGroup.MISSING,
        "Chưa phân công", "—", "30/10/2026", 0, emptyList()
    ),
    record(
        "PC11", FormStatus.DRAFT, RecordGroup.DUE_SOON,
        "Người phụ trách A", "14/10/2026", "20/10/2026", 1,
        listOf(
            "v2 · 14/10/2026 · Người phụ trách A · Cập nhật bản nháp",
            "v1 · 10/10/2026 · Người phụ trách A · Tạo từ mẫu"
        )
    ),
    record(
        "PC12", FormStatus.WAIT_SIGN, RecordGroup.IN_PROGRESS,
        "Người phụ trách B", "12/10/2026", "25/10/2026", 2,
        listOf("v1 · 12/10/2026 · Người phụ trách B · Hoàn thiện, chờ ký")
    ),
    record(
        "PC13", FormStatus.SUBMITTED, RecordGroup.SUBMITTED,
        "Người phụ trách A", "05/10/2026", "15/11/2026", 3,
        listOf(
            "v2 · 05/10/2026 · Người phụ trách A · Đã gửi (quy trình nội bộ)",
            "v1 · 01/10/2026 · Người phụ trách A · Ký xong"
        )
    ),
    record(
        "PC14", FormStatus.NEED_MORE, RecordGroup.NEED_MORE,
        "Người phụ trách C", "08/10/2026", "18/10/2026", 2,
        listOf(
            "v3 · 08/10/2026 · Người phụ trách C · Nhận yêu cầu bổ sung",
            "v2 · 02/10/2026 · Người phụ trách C · Đã gửi",
            "v1 · 28/09/2026 · Người phụ trách C · Tạo từ mẫu"
        )
    ),
    record(
        "PC15", FormStatus.ACCEPTED, RecordGroup.ACCEPTED,
        "Người phụ trách B", "20/09/2026", "—", 4,
        listOf("v2 · 20/09/2026 · Người phụ trách B · Có xác nhận tiếp nhận")
    )
)

// ---------- Màn hình tab ----------
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RecordTrackingTab() {
    var selected by remember { mutableStateOf<RecordGroup?>(null) }
    val filtered = sampleRecords.filter { selected == null || it.group == selected }

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
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                item {
                    FilterChip(
                        selected = selected == null,
                        onClick = { selected = null },
                        label = { Text("Tất cả (${sampleRecords.size})") },
                        colors = chipColors
                    )
                }
                items(RecordGroup.entries) { group ->
                    val count = sampleRecords.count { it.group == group }
                    FilterChip(
                        selected = selected == group,
                        onClick = { selected = if (selected == group) null else group },
                        label = { Text("${group.label} ($count)") },
                        colors = chipColors
                    )
                }
            }
        }
        item {
            Text(
                "Trạng thái phản ánh quy trình nội bộ của cơ sở.",
                style = MaterialTheme.typography.bodySmall,
                color = PcccColors.TextSecondary
            )
        }
        if (filtered.isEmpty()) {
            item {
                Text(
                    "Không có hồ sơ trong nhóm này",
                    color = PcccColors.TextSecondary,
                    modifier = Modifier.padding(vertical = 24.dp)
                )
            }
        } else {
            items(filtered, key = { it.code }) { RecordCard(it) }
        }
    }
}

// ---------- Thẻ hồ sơ ----------
@Composable
private fun RecordCard(record: FormRecord) {
    var expanded by remember { mutableStateOf(false) }
    val urgent = record.group == RecordGroup.DUE_SOON || record.group == RecordGroup.NEED_MORE

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, PcccColors.Outline)
    ) {
        Column(Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    record.code,
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    style = MaterialTheme.typography.labelLarge,
                    modifier = Modifier
                        .background(PcccColors.Burgundy, RoundedCornerShape(8.dp))
                        .padding(horizontal = 10.dp, vertical = 4.dp)
                )
                Spacer(Modifier.weight(1f))
                StatusChip(record.status)
            }
            Spacer(Modifier.height(8.dp))
            Text(record.name, fontWeight = FontWeight.Bold, color = PcccColors.TextPrimary)
            Spacer(Modifier.height(8.dp))
            HorizontalDivider(color = PcccColors.Outline)
            Spacer(Modifier.height(8.dp))

            InfoLine("Người phụ trách", record.owner)
            InfoLine("Ngày lập/cập nhật", record.updatedAt)
            InfoLine("Ngày đến hạn", record.dueDate, highlight = urgent)
            InfoLine(
                "Tệp đính kèm",
                if (record.attachments == 0) "Chưa có" else "${record.attachments} tệp"
            )

            if (expanded) {
                Spacer(Modifier.height(8.dp))
                HistoryList(record.history)
            }

            Spacer(Modifier.height(8.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                TextButton(onClick = { expanded = !expanded }) {
                    Text("Lịch sử xử lý", color = PcccColors.Bronze)
                    Icon(
                        if (expanded) Icons.Default.KeyboardArrowUp else Icons.Default.KeyboardArrowDown,
                        contentDescription = null,
                        tint = PcccColors.Bronze
                    )
                }
                Spacer(Modifier.weight(1f))
                OutlinedButton(
                    onClick = { /* TODO: mở hoặc tạo hồ sơ */ },
                    border = BorderStroke(1.dp, PcccColors.Burgundy)
                ) {
                    Text(
                        if (record.status == FormStatus.NOT_CREATED) "Tạo hồ sơ" else "Mở hồ sơ",
                        color = PcccColors.Burgundy
                    )
                }
            }
        }
    }
}

@Composable
private fun InfoLine(label: String, value: String, highlight: Boolean = false) {
    Row(Modifier.padding(vertical = 2.dp)) {
        Text(
            label,
            modifier = Modifier.width(140.dp),
            style = MaterialTheme.typography.bodySmall,
            color = PcccColors.TextSecondary
        )
        Text(
            value,
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = if (highlight) FontWeight.Bold else FontWeight.Medium,
            color = if (highlight) PcccColors.Burgundy else PcccColors.TextPrimary
        )
    }
}

@Composable
private fun HistoryList(history: List<String>) {
    Column(
        Modifier
            .fillMaxWidth()
            .background(PcccColors.BronzeSoft, RoundedCornerShape(12.dp))
            .padding(12.dp)
    ) {
        if (history.isEmpty()) {
            Text(
                "Chưa có lịch sử xử lý",
                style = MaterialTheme.typography.bodySmall,
                color = PcccColors.TextSecondary
            )
        } else {
            history.forEachIndexed { index, line ->
                if (index > 0) Spacer(Modifier.height(6.dp))
                Row(verticalAlignment = Alignment.Top) {
                    Box(
                        Modifier
                            .padding(top = 6.dp)
                            .size(8.dp)
                            .background(PcccColors.Bronze, CircleShape)
                    )
                    Spacer(Modifier.width(8.dp))
                    Text(
                        line,
                        style = MaterialTheme.typography.bodySmall,
                        color = PcccColors.TextPrimary
                    )
                }
            }
        }
    }
}