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

// 8 trạng thái hồ sơ theo APP_PCCC.md (mục 1)
enum class FormStatus(val label: String) {
    NOT_CREATED("Chưa lập"),
    DRAFT("Bản nháp"),
    WAIT_SIGN("Chờ ký"),
    WAIT_SUBMIT("Chờ nộp"),
    SUBMITTED("Đã nộp"),
    NEED_MORE("Yêu cầu bổ sung"),
    ACCEPTED("Đã tiếp nhận"),
    EXPIRED("Hết hiệu lực")
}

@Composable
fun StatusChip(status: FormStatus) {
    val (bg, fg) = when (status) {
        FormStatus.NOT_CREATED -> Color(0xFFF1EDEA) to PcccColors.TextSecondary
        FormStatus.NEED_MORE, FormStatus.EXPIRED -> PcccColors.BurgundySoft to PcccColors.Burgundy
        FormStatus.ACCEPTED -> PcccColors.Burgundy to Color.White
        else -> PcccColors.BronzeSoft to Color(0xFF8A6422)
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