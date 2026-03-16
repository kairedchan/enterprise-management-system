<template>
  <div class="app-container">
    <!-- 顶部导航栏 -->
    <el-header class="header">
      <div class="header-left">
        <el-icon size="24" class="logo-icon"><OfficeBuilding /></el-icon>
        <span class="app-title">企业管理系统</span>
      </div>
      <div class="header-right">
        <el-dropdown>
          <span class="el-dropdown-link">
            <el-avatar size="small" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
            <span class="user-name">管理员</span>
            <el-icon class="el-icon--right"><arrow-down /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item>个人中心</el-dropdown-item>
              <el-dropdown-item>系统设置</el-dropdown-item>
              <el-dropdown-item divided>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </el-header>

    <!-- 主布局 -->
    <el-container class="main-container">
      <!-- 侧边栏 -->
      <el-aside width="200px" class="sidebar">
        <el-menu
          default-active="1"
          class="el-menu-vertical-demo"
          @open="handleOpen"
          @close="handleClose"
        >
          <el-menu-item index="1">
            <el-icon><House /></el-icon>
            <span>首页</span>
          </el-menu-item>
          <el-menu-item index="2">
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </el-menu-item>
          <el-menu-item index="3">
            <el-icon><Document /></el-icon>
            <span>文档管理</span>
          </el-menu-item>
          <el-menu-item index="4">
            <el-icon><DataLine /></el-icon>
            <span>数据统计</span>
          </el-menu-item>
          <el-menu-item index="5">
            <el-icon><Setting /></el-icon>
            <span>系统设置</span>
          </el-menu-item>
        </el-menu>
      </el-aside>

      <!-- 主内容区 -->
      <el-main class="main-content">
        <div class="content-header">
          <h2>仪表板</h2>
          <div class="header-actions">
            <el-button type="primary" size="small" @click="handleRefresh">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
            <el-button size="small" @click="handleExport">
              <el-icon><Download /></el-icon>
              导出
            </el-button>
          </div>
        </div>

        <!-- 数据卡片 -->
        <div class="card-container">
          <el-card shadow="hover" class="stat-card">
            <template #header>
              <div class="card-header">
                <el-icon color="#409EFF"><User /></el-icon>
                <span>用户总数</span>
              </div>
            </template>
            <div class="card-content">
              <h3>1,245</h3>
              <p class="card-tip">较上月增长 12.5%</p>
            </div>
          </el-card>

          <el-card shadow="hover" class="stat-card">
            <template #header>
              <div class="card-header">
                <el-icon color="#67C23A"><Document /></el-icon>
                <span>文档数量</span>
              </div>
            </template>
            <div class="card-content">
              <h3>5,678</h3>
              <p class="card-tip">今日新增 23 个</p>
            </div>
          </el-card>

          <el-card shadow="hover" class="stat-card">
            <template #header>
              <div class="card-header">
                <el-icon color="#E6A23C"><DataLine /></el-icon>
                <span>访问量</span>
              </div>
            </template>
            <div class="card-content">
              <h3>89,456</h3>
              <p class="card-tip">较昨日增长 8.2%</p>
            </div>
          </el-card>

          <el-card shadow="hover" class="stat-card">
            <template #header>
              <div class="card-header">
                <el-icon color="#F56C6C"><Message /></el-icon>
                <span>未读消息</span>
              </div>
            </template>
            <div class="card-content">
              <h3>18</h3>
              <p class="card-tip">点击查看详情</p>
            </div>
          </el-card>
        </div>

        <!-- 表格 -->
        <el-card shadow="never" class="table-card">
          <template #header>
            <div class="table-header">
              <span>最近操作记录</span>
              <el-button type="primary" size="small" plain @click="handleViewAll">
                查看全部
              </el-button>
            </div>
          </template>
          <el-table :data="tableData" style="width: 100%">
            <el-table-column prop="time" label="时间" width="180" />
            <el-table-column prop="operator" label="操作人" width="120" />
            <el-table-column prop="action" label="操作内容" />
            <el-table-column prop="status" label="状态" width="100">
              <template #default="scope">
                <el-tag :type="scope.row.status === '成功' ? 'success' : 'warning'" size="small">
                  {{ scope.row.status }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
          <div class="table-pagination">
            <el-pagination
              v-model:current-page="currentPage"
              v-model:page-size="pageSize"
              :page-sizes="[10, 20, 30, 40]"
              :background="true"
              layout="total, sizes, prev, pager, next, jumper"
              :total="100"
            />
          </div>
        </el-card>
      </el-main>
    </el-container>

    <!-- 底部 -->
    <el-footer class="footer">
      <div class="footer-content">
        <span>© 2024 企业管理系统 版权所有</span>
        <span>版本号: v1.0.0</span>
      </div>
    </el-footer>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import {
  House,
  User,
  Document,
  DataLine,
  Setting,
  Refresh,
  Download,
  Message,
  OfficeBuilding,
  ArrowDown
} from '@element-plus/icons-vue'

const currentPage = ref(1)
const pageSize = ref(10)

const tableData = ref([
  {
    time: '2024-03-16 09:30:25',
    operator: '张三',
    action: '新建用户账号',
    status: '成功'
  },
  {
    time: '2024-03-16 10:15:42',
    operator: '李四',
    action: '更新系统配置',
    status: '成功'
  },
  {
    time: '2024-03-16 11:20:18',
    operator: '王五',
    action: '文档批量上传',
    status: '成功'
  },
  {
    time: '2024-03-16 13:45:33',
    operator: '赵六',
    action: '数据备份',
    status: '进行中'
  },
  {
    time: '2024-03-16 14:30:55',
    operator: '孙七',
    action: '用户权限修改',
    status: '失败'
  }
])

const handleOpen = (key: string, keyPath: string[]) => {
  console.log('handleOpen', key, keyPath)
}

const handleClose = (key: string, keyPath: string[]) => {
  console.log('handleClose', key, keyPath)
}

const handleRefresh = () => {
  console.log('刷新数据')
  // 这里可以添加刷新数据的逻辑
}

const handleExport = () => {
  console.log('导出数据')
  // 这里可以添加导出数据的逻辑
}

const handleViewAll = () => {
  console.log('查看全部记录')
  // 这里可以添加查看全部的逻辑
}
</script>

<style scoped>
.app-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.header {
  background: #001529;
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  height: 60px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.logo-icon {
  color: #409EFF;
}

.app-title {
  font-size: 20px;
  font-weight: bold;
}

.header-right {
  display: flex;
  align-items: center;
}

.el-dropdown-link {
  display: flex;
  align-items: center;
  gap: 8px;
  color: white;
  cursor: pointer;
}

.user-name {
  font-size: 14px;
}

.main-container {
  flex: 1;
  overflow: hidden;
}

.sidebar {
  background: #fff;
  border-right: 1px solid #e4e7ed;
}

.el-menu-vertical-demo {
  height: 100%;
  border-right: none;
}

.main-content {
  padding: 20px;
  background: #f0f2f5;
  overflow-y: auto;
}

.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.content-header h2 {
  margin: 0;
  color: #303133;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.card-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  cursor: pointer;
  transition: transform 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
}

.card-content h3 {
  margin: 0 0 8px 0;
  font-size: 28px;
  color: #303133;
}

.card-tip {
  margin: 0;
  font-size: 12px;
  color: #909399;
}

.table-card {
  margin-top: 20px;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.table-pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.footer {
  background: #f0f2f5;
  color: #909399;
  font-size: 12px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-top: 1px solid #e4e7ed;
}

.footer-content {
  display: flex;
  gap: 20px;
}

@media (max-width: 768px) {
  .card-container {
    grid-template-columns: 1fr;
  }
  
  .sidebar {
    width: 60px !important;
  }
}
</style>