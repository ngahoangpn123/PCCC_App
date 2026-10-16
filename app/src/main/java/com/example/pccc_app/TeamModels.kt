package com.example.pccc_app

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.pccc_app.ui.theme.PcccColors

// 4 tình trạng hoạt động theo APP_PCCC.md (mục 2.A)
enum class MemberStatus(val label: String) {
    ACTIVE("Đang tham gia"),
    AWAY("Tạm vắng"),
    ROLE_CHANGED("Thay đổi nhiệm vụ"),
    LEFT("Đã thôi tham gia")
}

data class TeamMember(
    val id: String,
    val name: String,
    val code: String,
    val phone: String,
    val email: String,
    val role: String,
    val duty: String,
    val status: MemberStatus,
    val training: List<String>,
    val certificates: List<String>,
    val roleHistory: List<String>
)

// Dữ liệu mẫu, chỉ để xem giao diện
val sampleMembers = listOf(
    TeamMember(
        "m1", "Nguyễn Văn A", "NS-001", "0900 000 001", "a@example.com",
        "Đội trưởng", "Chỉ huy tại chỗ, phân công ca trực", MemberStatus.ACTIVE,
        listOf("Huấn luyện nghiệp vụ PCCC (09/2026) · Đạt"),
        listOf("Chứng nhận nghiệp vụ PCCC · hiệu lực đến 12/2027"),
        listOf("01/2026 · Được giao làm Đội trưởng")
    ),
    TeamMember(
        "m2", "Trần Thị B", "NS-002", "0900 000 002", "b@example.com",
        "Đội phó", "Phụ trách thiết bị và kiểm tra", MemberStatus.ACTIVE,
        listOf("Huấn luyện nghiệp vụ PCCC (09/2026) · Đạt"),
        listOf("Chứng nhận nghiệp vụ PCCC · hiệu lực đến 06/2027"),
        listOf("01/2026 · Được giao làm Đội phó", "03/2026 · Thêm nhiệm vụ kiểm tra thiết bị")
    ),
    TeamMember(
        "m3", "Lê Văn C", "NS-003", "0900 000 003", "c@example.com",
        "Thành viên", "Trực ca sáng", MemberStatus.ACTIVE,
        listOf("Huấn luyện nghiệp vụ PCCC (09/2026) · Cần bổ sung"),
        emptyList(),
        listOf("02/2026 · Tham gia đội")
    ),
    TeamMember(
        "m4", "Phạm Thị D", "NS-004", "0900 000 004", "d@example.com",
        "Thành viên", "Trực ca chiều", MemberStatus.AWAY,
        emptyList(),
        listOf("Chứng nhận nghiệp vụ PCCC · hiệu lực đến 09/2027"),
        listOf("02/2026 · Tham gia đội", "10/2026 · Tạm vắng")
    ),
    TeamMember(
        "m5", "Hoàng Văn E", "NS-005", "0900 000 005", "e@example.com",
        "Thành viên", "Cứu nạn, cứu hộ", MemberStatus.ROLE_CHANGED,
        listOf("Huấn luyện cứu nạn cứu hộ (08/2026) · Đạt"),
        emptyList(),
        listOf("02/2026 · Tham gia đội", "10/2026 · Chuyển sang nhiệm vụ cứu nạn")
    ),
    TeamMember(
        "m6", "Vũ Thị F", "NS-006", "0900 000 006", "f@example.com",
        "Thành viên", "Đã bàn giao nhiệm vụ", MemberStatus.LEFT,
        emptyList(),
        emptyList(),
        listOf("02/2026 · Tham gia đội", "08/2026 · Thôi tham gia")
    )
)

@Composable
fun MemberStatusChip(status: MemberStatus) {
    val (bg, fg) = when (status) {
        MemberStatus.ACTIVE -> PcccColors.Burgundy to Color.White
        MemberStatus.AWAY -> PcccColors.BronzeSoft to Color(0xFF8A6422)
        MemberStatus.ROLE_CHANGED -> PcccColors.BurgundySoft to PcccColors.Burgundy
        MemberStatus.LEFT -> Color(0xFFF1EDEA) to PcccColors.TextSecondary
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