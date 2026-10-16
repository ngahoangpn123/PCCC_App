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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
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

// ---------- Dữ liệu mẫu tĩnh ----------
private data class UrgentTask(val title: String, val subtitle: String, val icon: ImageVector)

private val urgentTasks = listOf(
    UrgentTask("Bổ sung hồ sơ còn thiếu", "Hồ sơ quản lý cơ sở · Cần rà soát", Icons.Default.Info),
    UrgentTask("Kiểm tra phương tiện", "Có thiết bị đến hạn kiểm tra", Icons.Default.Build),
    UrgentTask("Xác nhận lịch trực", "Cần xác nhận quân số ca trực", Icons.Default.Person)
)

private data class HomeCategory(
    val title: String,
    val subtitle: String,
    val icon: ImageVector,
    val module: FunctionModule?   // null = chưa có màn hình
)

private val categories = listOf(
    HomeCategory("Thông tin cơ sở", "Thông tin chung, hồ sơ", Icons.Default.Info, FunctionModule.FACILITY),
    HomeCategory("Đội PCCC & CNCH", "Thành viên, lịch trực", Icons.Default.Person, FunctionModule.TEAM),
    HomeCategory("Phương tiện", "Thiết bị, bảo dưỡng", Icons.Default.Build, FunctionModule.EQUIPMENT),
    HomeCategory("Huấn luyện", "Kế hoạch, kết quả", Icons.Default.Star, FunctionModule.TRAINING),
    HomeCategory("Phương án & diễn tập", "Kịch bản, kết quả", Icons.Default.Warning, FunctionModule.DRILL),
    HomeCategory("Báo cáo tổng hợp", "Tiến độ, tồn đọng", Icons.Default.CheckCircle, null)
)

// ---------- Màn hình chính ----------
@Composable
fun HomeScreen(
    onOpenModule: (FunctionModule) -> Unit,
    onOpenNotifications: () -> Unit
) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(PcccColors.Background),
        contentPadding = PaddingValues(bottom = 24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item { HomeHeader(onBellClick = onOpenNotifications) }
        item { UrgentSection(onViewAll = onOpenNotifications) }
        item { CreateTaskBar() }
        item {
            Column(Modifier.padding(horizontal = 16.dp)) {
                Text(
                    "Danh mục quản lý",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = PcccColors.TextPrimary
                )
                Spacer(Modifier.height(12.dp))
                categories.chunked(2).forEachIndexed { rowIndex, rowItems ->
                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        rowItems.forEachIndexed { colIndex, item ->
                            CategoryCard(
                                item = item,
                                tintGold = (rowIndex + colIndex) % 2 == 1,
                                modifier = Modifier.weight(1f),
                                onClick = { item.module?.let(onOpenModule) }
                            )
                        }
                    }
                    Spacer(Modifier.height(12.dp))
                }
            }
        }
    }
}

// ---------- 1. Đầu trang ----------
@Composable
private fun HomeHeader(onBellClick: () -> Unit) {
    Column(
        Modifier
            .fillMaxWidth()
            .background(
                PcccColors.Burgundy,
                RoundedCornerShape(bottomStart = 24.dp, bottomEnd = 24.dp)
            )
            .statusBarsPadding()
            .padding(16.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier
                    .size(40.dp)
                    .background(Color.White.copy(alpha = 0.15f), RoundedCornerShape(12.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Default.CheckCircle, contentDescription = null, tint = Color.White)
            }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text("PCCC & CNCH", color = Color.White, fontWeight = FontWeight.Bold)
                Text(
                    "Hệ thống quản lý cơ sở",
                    color = Color.White.copy(alpha = 0.85f),
                    style = MaterialTheme.typography.bodySmall
                )
            }
            IconButton(onClick = onBellClick) {
                Icon(Icons.Default.Notifications, contentDescription = "Thông báo", tint = Color.White)
            }
        }
        Spacer(Modifier.height(16.dp))
        Text("Xin chào,", color = Color.White.copy(alpha = 0.85f))
        Text(
            "Người đứng đầu cơ sở",
            color = Color.White,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold
        )
        Spacer(Modifier.height(12.dp))
        Row(
            Modifier
                .fillMaxWidth()
                .background(Color.White.copy(alpha = 0.15f), RoundedCornerShape(14.dp))
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(Modifier.weight(1f)) {
                Text(
                    "CƠ SỞ ĐANG QUẢN LÝ",
                    color = PcccColors.BronzeSoft,
                    style = MaterialTheme.typography.labelSmall
                )
                Text("Tên cơ sở của bạn", color = Color.White, fontWeight = FontWeight.Bold)
                Text(
                    "Mã cơ sở · Địa chỉ",
                    color = Color.White.copy(alpha = 0.85f),
                    style = MaterialTheme.typography.bodySmall
                )
            }
            Icon(Icons.Default.ArrowDropDown, contentDescription = null, tint = Color.White)
        }
    }
}

// ---------- 2. Cần xử lý ngay ----------
@Composable
private fun UrgentSection(onViewAll: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, PcccColors.Outline)
    ) {
        Column(Modifier.padding(vertical = 8.dp)) {
            Row(
                Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Default.Warning,
                    contentDescription = null,
                    tint = PcccColors.Burgundy,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    "Cần xử lý ngay",
                    fontWeight = FontWeight.Bold,
                    color = PcccColors.TextPrimary,
                    modifier = Modifier.weight(1f)
                )
                Text(
                    "${urgentTasks.size} việc",
                    color = PcccColors.Burgundy,
                    style = MaterialTheme.typography.labelMedium,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier
                        .background(PcccColors.BurgundySoft, RoundedCornerShape(50))
                        .padding(horizontal = 10.dp, vertical = 4.dp)
                )
            }
            urgentTasks.forEachIndexed { index, task ->
                HorizontalDivider(color = PcccColors.Outline)
                TaskRow(task, tintGold = index % 2 == 1)
            }
            Spacer(Modifier.height(8.dp))
            OutlinedButton(
                onClick = onViewAll,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                border = BorderStroke(1.dp, PcccColors.Burgundy)
            ) {
                Text("Xem tất cả công việc", color = PcccColors.Burgundy)
            }
        }
    }
}

@Composable
private fun TaskRow(task: UrgentTask, tintGold: Boolean) {
    Row(
        Modifier
            .fillMaxWidth()
            .clickable { /* TODO: mở nhiệm vụ, làm ở bước nối dữ liệu */ }
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        IconBox(task.icon, tintGold)
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(task.title, fontWeight = FontWeight.SemiBold, color = PcccColors.TextPrimary)
            Text(
                task.subtitle,
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

// ---------- 3. Tạo nhiệm vụ mới ----------
@Composable
private fun CreateTaskBar() {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .clip(RoundedCornerShape(16.dp))
            .clickable { /* TODO: màn hình tạo nhiệm vụ */ },
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = PcccColors.BronzeSoft),
        border = BorderStroke(1.dp, PcccColors.Bronze.copy(alpha = 0.5f))
    ) {
        Row(
            Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(Icons.Default.Add, contentDescription = null, tint = PcccColors.Bronze)
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text("Tạo nhiệm vụ mới", fontWeight = FontWeight.Bold, color = PcccColors.TextPrimary)
                Text(
                    "Lập lịch kiểm tra, giao việc hoặc tạo kế hoạch.",
                    style = MaterialTheme.typography.bodySmall,
                    color = PcccColors.TextSecondary
                )
            }
            Icon(
                Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint = PcccColors.Bronze
            )
        }
    }
}

// ---------- 4. Danh mục quản lý ----------
@Composable
private fun CategoryCard(
    item: HomeCategory,
    tintGold: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Card(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp))
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, PcccColors.Outline)
    ) {
        Column(Modifier.padding(16.dp)) {
            IconBox(item.icon, tintGold)
            Spacer(Modifier.height(12.dp))
            Text(
                item.title,
                fontWeight = FontWeight.Bold,
                color = PcccColors.TextPrimary,
                maxLines = 1
            )
            Text(
                item.subtitle,
                style = MaterialTheme.typography.bodySmall,
                color = PcccColors.TextSecondary,
                maxLines = 1
            )
        }
    }
}

// ---------- Thành phần dùng chung ----------
@Composable
private fun IconBox(icon: ImageVector, tintGold: Boolean) {
    Box(
        Modifier
            .size(40.dp)
            .background(
                if (tintGold) PcccColors.BronzeSoft else PcccColors.BurgundySoft,
                RoundedCornerShape(12.dp)
            ),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            icon,
            contentDescription = null,
            tint = if (tintGold) PcccColors.Bronze else PcccColors.Burgundy
        )
    }
}