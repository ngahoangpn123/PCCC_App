package com.example.pccc_app.ui

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.pccc_app.data.AppDatabase
import com.example.pccc_app.data.Facility
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class FacilityViewModel(application: Application) : AndroidViewModel(application) {

    private val dao = AppDatabase.getInstance(application).facilityDao()

    // Danh sách cơ sở, tự cập nhật khi bảng thay đổi
    val facilities: StateFlow<List<Facility>> = dao.getAll()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    // TẠM THỜI: thêm một cơ sở mẫu để kiểm tra (sẽ bỏ ở phần 2)
    fun addFacility(facility: Facility) {
        viewModelScope.launch {
            dao.insert(facility)
        }
    }

    fun deleteFacility(facility: Facility) {
        viewModelScope.launch {
            dao.delete(facility)
        }
    }
}