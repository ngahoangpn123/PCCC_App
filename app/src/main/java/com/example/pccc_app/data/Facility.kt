package com.example.pccc_app.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "facility")
data class Facility(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,                 // Tên cơ sở
    val address: String,              // Địa chỉ
    val headName: String,             // Họ tên người đứng đầu
    val headPosition: String,         // Chức vụ người đứng đầu
    val phone: String = "",           // Số điện thoại liên hệ
    val businessType: String = "",    // Loại hình hoạt động
    val areaM2: Double? = null,       // Diện tích (m²)
    val floors: Int? = null,          // Số tầng
    val createdAt: Long = System.currentTimeMillis()
)