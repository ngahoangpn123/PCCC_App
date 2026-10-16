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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
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

// ---------- Màn hình tab ----------
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TeamMembersTab(initialOpenId: String? = null, onSheetClosed: () -> Unit = {}) {
    var query by remember { mutableStateOf("") }
    var selected by remember { mutableStateOf<MemberStatus?>(null) }
    var opened by remember(initialOpenId) {
        mutableStateOf(sampleMembers.firstOrNull { it.id == initialOpenId })
    }

    val q = query.trim().lowercase()
    val filtered = sampleMembers.filter { m ->
        val matchText = q.isEmpty() || listOf(m.name, m.code, m.role, m.duty)
            .any { it.lowercase().contains(q) }
        val matchStatus = selected == null || m.status == selected
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
        item { StatsRow() }
        item {
            OutlinedTextField(
                value = query,
                onValueChange = { query = it },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                shape = RoundedCornerShape(14.dp),
                placeholder = { Text("Tìm theo tên, mã, vai trò, nhiệm vụ") },
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
                items(MemberStatus.entries) { status ->
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
                    "Không tìm thấy thành viên phù hợp",
                    color = PcccColors.TextSecondary,
                    modifier = Modifier.padding(vertical = 24.dp)
                )
            }
        } else {
            items(filtered, key = { it.id }) { member ->
                MemberCard(member, onClick = { opened = member })
            }
        }
    }

    opened?.let { member ->
        MemberDetailSheet(member, onDismiss = { opened = null; onSheetClosed() })
    }
}

// ---------- Thống kê ----------
@Composable
private fun StatsRow() {
    val total = sampleMembers.size
    val active = sampleMembers.count { it.status == MemberStatus.ACTIVE }
    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        StatBox("Tổng thành viên", total.toString(), PcccColors.BurgundySoft, PcccColors.Burgundy, Modifier.weight(1f))
        StatBox("Đang tham gia", active.toString(), PcccColors.BronzeSoft, Color(0xFF8A6422), Modifier.weight(1f))
    }
}

@Composable
private fun StatBox(label: String, value: String, bg: Color, fg: Color, modifier: Modifier) {
    Column(
        modifier
            .background(bg, RoundedCornerShape(14.dp))
            .padding(12.dp)
    ) {
        Text(value, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold, color = fg)
        Text(label, style = MaterialTheme.typography.bodySmall, color = PcccColors.TextSecondary)
    }
}

// ---------- Thẻ thành viên ----------
@Composable
private fun MemberCard(member: TeamMember, onClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, PcccColors.Outline)
    ) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Avatar(member.name, 44)
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(member.name, fontWeight = FontWeight.Bold, color = PcccColors.TextPrimary)
                Text(
                    "${member.code} · ${member.role}",
                    style = MaterialTheme.typography.bodySmall,
                    color = PcccColors.TextSecondary
                )
                Text(
                    member.duty,
                    style = MaterialTheme.typography.bodySmall,
                    color = PcccColors.TextSecondary,
                    maxLines = 1
                )
                Spacer(Modifier.height(6.dp))
                MemberStatusChip(member.status)
                val issues = memberIssues(member)
                if (issues.isNotEmpty()) {
                    Spacer(Modifier.height(4.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        issues.forEach { IssueTag(it) }
                    }
                }
            }
            Icon(
                Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint = PcccColors.TextSecondary
            )
        }
    }
}

@Composable
private fun Avatar(name: String, sizeDp: Int) {
    Box(
        Modifier
            .size(sizeDp.dp)
            .background(PcccColors.BurgundySoft, CircleShape),
        contentAlignment = Alignment.Center
    ) {
        Text(
            name.trim().takeLast(1).uppercase(),
            color = PcccColors.Burgundy,
            fontWeight = FontWeight.Bold
        )
    }
}

// ---------- Hồ sơ thành viên (bảng trượt) ----------
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MemberDetailSheet(member: TeamMember, onDismiss: () -> Unit) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = Color.White
    ) {
        Column(
            Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(start = 16.dp, end = 16.dp, bottom = 32.dp)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Avatar(member.name, 56)
                Spacer(Modifier.width(12.dp))
                Column {
                    Text(
                        member.name,
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        color = PcccColors.Burgundy
                    )
                    Text(
                        "Mã nhân sự: ${member.code}",
                        style = MaterialTheme.typography.bodySmall,
                        color = PcccColors.TextSecondary
                    )
                }
            }

            DetailSection("Thông tin liên hệ") {
                DetailLine("Điện thoại", member.phone)
                DetailLine("Email", member.email)
            }
            DetailSection("Vai trò và nhiệm vụ") {
                DetailLine("Vai trò trong đội", member.role)
                DetailLine("Nhiệm vụ được phân công", member.duty)
            }
            DetailSection("Tình trạng hoạt động") {
                MemberStatusChip(member.status)
            }
            DetailSection("Huấn luyện và chứng nhận (nếu áp dụng)") {
                BulletLines("Huấn luyện, kết quả", member.training)
                Spacer(Modifier.height(8.dp))
                BulletLines("Chứng nhận cần theo dõi", member.certificates)
            }
            DetailSection("Lịch sử thay đổi vai trò, phân công") {
                BulletLines(null, member.roleHistory)
            }
        }
    }
}

@Composable
private fun DetailSection(title: String, content: @Composable () -> Unit) {
    Spacer(Modifier.height(16.dp))
    HorizontalDivider(color = PcccColors.Outline)
    Spacer(Modifier.height(12.dp))
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
            Modifier
                .size(width = 4.dp, height = 16.dp)
                .background(PcccColors.Bronze, RoundedCornerShape(2.dp))
        )
        Spacer(Modifier.width(8.dp))
        Text(title, fontWeight = FontWeight.Bold, color = PcccColors.Burgundy)
    }
    Spacer(Modifier.height(8.dp))
    content()
}

@Composable
private fun DetailLine(label: String, value: String) {
    Column(Modifier.padding(vertical = 4.dp)) {
        Text(label, style = MaterialTheme.typography.bodySmall, color = PcccColors.TextSecondary)
        Text(value, fontWeight = FontWeight.Medium, color = PcccColors.TextPrimary)
    }
}

@Composable
private fun BulletLines(label: String?, lines: List<String>) {
    if (label != null) {
        Text(label, style = MaterialTheme.typography.bodySmall, color = PcccColors.TextSecondary)
    }
    if (lines.isEmpty()) {
        Text("Chưa có thông tin", style = MaterialTheme.typography.bodyMedium, color = PcccColors.TextSecondary)
    } else {
        lines.forEach { line ->
            Row(Modifier.padding(vertical = 2.dp), verticalAlignment = Alignment.Top) {
                Box(
                    Modifier
                        .padding(top = 7.dp)
                        .size(6.dp)
                        .background(PcccColors.Bronze, CircleShape)
                )
                Spacer(Modifier.width(8.dp))
                Text(line, style = MaterialTheme.typography.bodyMedium, color = PcccColors.TextPrimary)
            }
        }
    }
}