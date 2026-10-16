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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.pccc_app.ui.theme.PcccColors

@Composable
fun FacilityInfoTab(onAddFacility: () -> Unit) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(PcccColors.Background),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item { SummaryCard() }
        item {
            InfoSection(
                title = "Đặc điểm cơ sở",
                rows = listOf(
                    "Loại hình" to "Cơ sở mẫu",
                    "Lĩnh vực hoạt động" to "Chưa cập nhật",
                    "Quy mô" to "Chưa cập nhật",
                    "Đặc điểm công trình" to "Chưa cập nhật"
                )
            )
        }
        item {
            InfoSection(
                title = "Người phụ trách",
                rows = listOf(
                    "Người đứng đầu cơ sở" to "Chưa cập nhật",
                    "Phụ trách PCCC & CNCH" to "Chưa cập nhật"
                )
            )
        }
        item {
            InfoSection(
                title = "Liên hệ và dữ liệu an toàn",
                rows = listOf(
                    "Điện thoại" to "Chưa cập nhật",
                    "Email" to "Chưa cập nhật",
                    "Dữ liệu quản lý an toàn" to "Chưa cập nhật"
                )
            )
        }
        item {
            OutlinedButton(
                onClick = onAddFacility,
                modifier = Modifier.fillMaxWidth(),
                border = BorderStroke(1.dp, PcccColors.Bronze)
            ) {
                Icon(Icons.Default.Add, contentDescription = null, tint = PcccColors.Bronze)
                Spacer(Modifier.width(8.dp))
                Text("Thêm cơ sở mới (tạm)", color = PcccColors.Bronze)
            }
        }
    }
}

@Composable
private fun SummaryCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = PcccColors.BurgundySoft)
    ) {
        Column(Modifier.padding(16.dp)) {
            Text(
                "Tên cơ sở của bạn",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = PcccColors.Burgundy
            )
            Spacer(Modifier.height(8.dp))
            IconLine(Icons.Default.Info, "Mã cơ sở: CS-0001")
            Spacer(Modifier.height(4.dp))
            IconLine(Icons.Default.LocationOn, "Địa chỉ cơ sở")
        }
    }
}

@Composable
private fun IconLine(icon: androidx.compose.ui.graphics.vector.ImageVector, text: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(icon, contentDescription = null, tint = PcccColors.Bronze, modifier = Modifier.size(18.dp))
        Spacer(Modifier.width(8.dp))
        Text(text, color = PcccColors.TextPrimary, style = MaterialTheme.typography.bodyMedium)
    }
}

@Composable
private fun InfoSection(title: String, rows: List<Pair<String, String>>) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, PcccColors.Outline)
    ) {
        Column(Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    Modifier
                        .size(width = 4.dp, height = 18.dp)
                        .background(PcccColors.Bronze, RoundedCornerShape(2.dp))
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    title,
                    fontWeight = FontWeight.Bold,
                    color = PcccColors.Burgundy,
                    style = MaterialTheme.typography.titleMedium
                )
            }
            Spacer(Modifier.height(8.dp))
            rows.forEachIndexed { index, (label, value) ->
                if (index > 0) HorizontalDivider(color = PcccColors.Outline)
                Column(Modifier.padding(vertical = 10.dp)) {
                    Text(
                        label,
                        style = MaterialTheme.typography.bodySmall,
                        color = PcccColors.TextSecondary
                    )
                    Text(value, fontWeight = FontWeight.SemiBold, color = PcccColors.TextPrimary)
                }
            }
        }
    }
}