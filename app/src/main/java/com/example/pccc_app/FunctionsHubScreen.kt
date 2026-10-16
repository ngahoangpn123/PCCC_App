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
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.pccc_app.ui.theme.PcccColors

private fun moduleIcon(module: FunctionModule): ImageVector = when (module) {
    FunctionModule.FACILITY -> Icons.Default.Info
    FunctionModule.TEAM -> Icons.Default.Person
    FunctionModule.EQUIPMENT -> Icons.Default.Build
    FunctionModule.TRAINING -> Icons.Default.Star
    FunctionModule.DRILL -> Icons.Default.Warning
}

@Composable
fun FunctionsHubScreen(onOpen: (FunctionModule) -> Unit) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(PcccColors.Background),
        contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 24.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item { HubHeader() }
        itemsIndexed(FunctionModule.entries) { index, module ->
            HubModuleRow(
                module = module,
                tintGold = index % 2 == 1,
                onClick = { onOpen(module) }
            )
        }
    }
}

@Composable
private fun HubHeader() {
    Column(
        Modifier
            .fillMaxWidth()
            .statusBarsPadding()
            .padding(top = 16.dp, bottom = 4.dp)
    ) {
        Text(
            "Quản lý",
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = PcccColors.Burgundy
        )
        Text(
            "Trung tâm 5 phân hệ nghiệp vụ và dữ liệu của cơ sở",
            style = MaterialTheme.typography.bodyMedium,
            color = PcccColors.TextSecondary
        )
        Spacer(Modifier.height(16.dp))
        Row(
            Modifier
                .fillMaxWidth()
                .background(PcccColors.BurgundySoft, RoundedCornerShape(14.dp))
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(Modifier.weight(1f)) {
                Text(
                    "CƠ SỞ ĐANG QUẢN LÝ",
                    style = MaterialTheme.typography.labelSmall,
                    color = PcccColors.Bronze,
                    fontWeight = FontWeight.Bold
                )
                Text("Tên cơ sở của bạn", fontWeight = FontWeight.Bold, color = PcccColors.TextPrimary)
                Text(
                    "Mã cơ sở · Địa chỉ",
                    style = MaterialTheme.typography.bodySmall,
                    color = PcccColors.TextSecondary
                )
            }
            Icon(Icons.Default.ArrowDropDown, contentDescription = null, tint = PcccColors.Burgundy)
        }
    }
}

@Composable
private fun HubModuleRow(module: FunctionModule, tintGold: Boolean, onClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, PcccColors.Outline)
    ) {
        Row(
            Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                Modifier
                    .size(48.dp)
                    .background(
                        if (tintGold) PcccColors.BronzeSoft else PcccColors.BurgundySoft,
                        RoundedCornerShape(14.dp)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    moduleIcon(module),
                    contentDescription = null,
                    tint = if (tintGold) PcccColors.Bronze else PcccColors.Burgundy
                )
            }
            Spacer(Modifier.width(14.dp))
            Column(Modifier.weight(1f)) {
                Text(module.title, fontWeight = FontWeight.Bold, color = PcccColors.TextPrimary)
                Text(
                    module.description,
                    style = MaterialTheme.typography.bodySmall,
                    color = PcccColors.TextSecondary
                )
            }
            Icon(
                Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint = PcccColors.TextSecondary
            )
        }
    }
}