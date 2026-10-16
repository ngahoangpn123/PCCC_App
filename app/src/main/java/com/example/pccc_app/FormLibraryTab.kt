package com.example.pccc_app

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
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

private data class FormTemplate(
    val code: String,
    val name: String,
    val purpose: String,
    val status: FormStatus
)

// TODO: thay tên và mục đích bằng thông tin thật của từng biểu mẫu
private fun form(code: String, status: FormStatus) = FormTemplate(
    code = code,
    name = "Tên biểu mẫu $code (cập nhật sau)",
    purpose = "Mục đích sử dụng (cập nhật sau)",
    status = status
)

private val sampleForms = listOf(
    form("PC01", FormStatus.SUBMITTED),
    form("PC11", FormStatus.DRAFT),
    form("PC12", FormStatus.WAIT_SIGN),
    form("PC13", FormStatus.WAIT_SUBMIT),
    form("PC14", FormStatus.NEED_MORE),
    form("PC15", FormStatus.ACCEPTED),
    form("PC16", FormStatus.EXPIRED),
    form("PC17", FormStatus.NOT_CREATED),
    form("PC18", FormStatus.NOT_CREATED),
    form("PC19", FormStatus.NOT_CREATED),
    form("PC20", FormStatus.NOT_CREATED),
    form("PC21", FormStatus.NOT_CREATED),
    form("PC22", FormStatus.NOT_CREATED),
    form("PC23", FormStatus.NOT_CREATED)
)

// ---------- Màn hình tab ----------
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FormLibraryTab() {
    var query by remember { mutableStateOf("") }
    var selected by remember { mutableStateOf<FormStatus?>(null) }

    val q = query.trim().lowercase()
    val filtered = sampleForms.filter { f ->
        val matchText = q.isEmpty() || listOf(f.code, f.name, f.purpose, f.status.label)
            .any { it.lowercase().contains(q) }
        val matchStatus = selected == null || f.status == selected
        matchText && matchStatus
    }

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
            OutlinedTextField(
                value = query,
                onValueChange = { query = it },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                shape = RoundedCornerShape(14.dp),
                placeholder = { Text("Tìm theo mã, tên, mục đích, trạng thái") },
                leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = PcccColors.Burgundy,
                    unfocusedBorderColor = PcccColors.Outline,
                    cursorColor = PcccColors.Burgundy
                )
            )
        }
        item {
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                item {
                    FilterChip(
                        selected = selected == null,
                        onClick = { selected = null },
                        label = { Text("Tất cả") },
                        colors = chipColors
                    )
                }
                items(FormStatus.entries) { status ->
                    FilterChip(
                        selected = selected == status,
                        onClick = { selected = if (selected == status) null else status },
                        label = { Text(status.label) },
                        colors = chipColors
                    )
                }
            }
        }
        if (filtered.isEmpty()) {
            item {
                Text(
                    "Không tìm thấy biểu mẫu phù hợp",
                    color = PcccColors.TextSecondary,
                    modifier = Modifier.padding(vertical = 24.dp)
                )
            }
        } else {
            items(filtered, key = { it.code }) { FormCard(it) }
        }
    }
}

// ---------- Thẻ biểu mẫu ----------
@Composable
private fun FormCard(form: FormTemplate) {
    var menuOpen by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, PcccColors.Outline)
    ) {
        Column(Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    form.code,
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    style = MaterialTheme.typography.labelLarge,
                    modifier = Modifier
                        .background(PcccColors.Burgundy, RoundedCornerShape(8.dp))
                        .padding(horizontal = 10.dp, vertical = 4.dp)
                )
                Spacer(Modifier.weight(1f))
                StatusChip(form.status)
            }
            Spacer(Modifier.height(8.dp))
            Text(form.name, fontWeight = FontWeight.Bold, color = PcccColors.TextPrimary)
            Text(
                form.purpose,
                style = MaterialTheme.typography.bodySmall,
                color = PcccColors.TextSecondary
            )
            Spacer(Modifier.height(12.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                OutlinedButton(
                    onClick = { /* TODO: tạo hoặc mở hồ sơ */ },
                    modifier = Modifier.weight(1f),
                    border = BorderStroke(1.dp, PcccColors.Burgundy)
                ) {
                    Text(
                        if (form.status == FormStatus.NOT_CREATED) "Tạo hồ sơ" else "Mở hồ sơ",
                        color = PcccColors.Burgundy
                    )
                }
                Column {
                    IconButton(onClick = { menuOpen = true }) {
                        Icon(
                            Icons.Default.MoreVert,
                            contentDescription = "Thêm thao tác",
                            tint = PcccColors.TextSecondary
                        )
                    }
                    DropdownMenu(expanded = menuOpen, onDismissRequest = { menuOpen = false }) {
                        DropdownMenuItem(
                            text = { Text("Xem hướng dẫn") },
                            onClick = { menuOpen = false /* TODO */ }
                        )
                        DropdownMenuItem(
                            text = { Text("Tải mẫu về") },
                            onClick = { menuOpen = false /* TODO */ }
                        )
                        DropdownMenuItem(
                            text = { Text("Tải bản đã điền lên") },
                            onClick = { menuOpen = false /* TODO */ }
                        )
                    }
                }
            }
        }
    }
}