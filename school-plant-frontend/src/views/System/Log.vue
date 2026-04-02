<template>
  <div class="p-6">
    <div class="mb-6 flex justify-between items-center">
      <h1 class="text-2xl font-bold">{{ pageTitle }}</h1>
      <!-- ... -->
    </div>

    <!-- Filter Form -->
    <a-card class="mb-6 shadow-sm border-none">
      <a-form layout="inline" :model="queryParams" @finish="handleSearch">
        <a-form-item label="操作人" v-if="isAdmin">
          <a-input
            v-model:value="queryParams.operatorName"
            placeholder="输入姓名"
            allow-clear
          />
        </a-form-item>
        <a-form-item label="模块">
          <a-select
            v-model:value="queryParams.module"
            placeholder="全部模块"
            style="width: 120px"
            allow-clear
          >
            <a-select-option value="PLANT">植物管理</a-select-option>
            <a-select-option value="ADOPTION">认养管理</a-select-option>
            <a-select-option value="ABNORMALITY">异常管理</a-select-option>
            <a-select-option value="USER">用户管理</a-select-option>
            <a-select-option value="SYSTEM">系统管理</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="操作类型">
          <a-select
            v-model:value="queryParams.operationType"
            placeholder="全部类型"
            style="width: 120px"
            allow-clear
          >
            <a-select-option value="INSERT">新增</a-select-option>
            <a-select-option value="UPDATE">修改</a-select-option>
            <a-select-option value="DELETE">删除</a-select-option>
            <a-select-option value="QUERY">查询</a-select-option>
            <a-select-option value="AUDIT">审核</a-select-option>
            <a-select-option value="LOGIN">登录</a-select-option>
            <a-select-option value="LOGOUT">登出</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-space>
            <a-button type="primary" html-type="submit">查询</a-button>
            <a-button @click="resetQuery">重置</a-button>
          </a-space>
        </a-form-item>
      </a-form>
    </a-card>

    <!-- Log Table -->
    <a-card class="shadow-sm border-none">
      
      <!-- Mobile List View -->
      <div class="md:hidden">
        <div
          v-for="record in dataSource"
          :key="record.id"
          class="bg-white p-4 mb-3 rounded-lg border border-gray-100 shadow-sm"
        >
          <div class="flex justify-between items-start mb-2">
            <span class="font-bold text-gray-900">{{ record.operationDesc }}</span>
            <a-tag :color="record.operationResult === 'SUCCESS' ? 'green' : 'red'">
              {{ record.operationResult === "SUCCESS" ? "成功" : "失败" }}
            </a-tag>
          </div>
          
          <div class="text-sm text-gray-500 mb-1">
            操作人: {{ record.operatorName }} ({{ formatRole(record.operatorRole) }})
          </div>
          <div class="flex gap-2 mb-1">
            <a-tag size="small">{{ formatModule(record.module) }}</a-tag>
            <a-tag size="small" :color="getOperationTypeColor(record.operationType)">
              {{ formatOperationType(record.operationType) }}
            </a-tag>
          </div>
          <div class="text-xs text-gray-400 flex justify-between mt-2">
            <span>{{ formatDate(record.createdAt) }}</span>
            <span>耗时: {{ formatExecutionTime(record.executionTime) }}</span>
          </div>
        </div>
        
        <!-- Mobile Pagination -->
        <div class="flex justify-center mt-4" v-if="dataSource.length > 0">
           <a-pagination 
             v-model:current="pagination.current" 
             :total="pagination.total" 
             :pageSize="pagination.pageSize" 
             @change="(page) => handleTableChange({ current: page, pageSize: pagination.pageSize })"
             simple 
           />
        </div>
      </div>

      <!-- Desktop Table View -->
      <a-table
        class="hidden md:block"
        :dataSource="dataSource"
        :columns="columns"
        :loading="loading"
        :pagination="pagination"
        @change="handleTableChange"
        rowKey="id"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'operatorRole'">
            {{ formatRole(record.operatorRole) }}
          </template>
          <template v-else-if="column.key === 'module'">
            {{ formatModule(record.module) }}
          </template>
          <template v-else-if="column.key === 'operationType'">
            <a-tag :color="getOperationTypeColor(record.operationType)">
              {{ formatOperationType(record.operationType) }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'operationResult'">
            <a-tag
              :color="record.operationResult === 'SUCCESS' ? 'green' : 'red'"
            >
              {{ record.operationResult === "SUCCESS" ? "成功" : "失败" }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'executionTime'">
            {{ formatExecutionTime(record.executionTime) }}
          </template>
          <template v-else-if="column.key === 'createdAt'">
            {{ formatDate(record.createdAt) }}
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted, computed } from "vue";
import { DownloadOutlined } from "@ant-design/icons-vue";
import {
  getLogList,
  getMyLogList,
  exportLogs,
  type LogQueryRequest,
  type OperationLog,
} from "@/api/log";
import { message } from "ant-design-vue";
import dayjs from "dayjs";

const loading = ref(false);
const dataSource = ref<OperationLog[]>([]);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showQuickJumper: true,
});

const queryParams = reactive({
  operatorName: "",
  module: undefined,
  operationType: undefined,
});

const role = ref(localStorage.getItem("role") || "USER");
const isAdmin = computed(() => role.value === "ADMIN");
const pageTitle = computed(() => (isAdmin.value ? "操作日志查询" : "个人处理记录"));

const formatRole = (role: string) => {
  const map: Record<string, string> = {
    ADMIN: "管理员",
    USER: "用户",
    MAINTAINER: "养护员",
  };
  return map[role] || role;
};

const formatModule = (module: string) => {
  const map: Record<string, string> = {
    PLANT: "植物管理",
    ADOPTION: "认养管理",
    ABNORMALITY: "异常管理",
    USER: "用户管理",
    SYSTEM: "系统管理",
  };
  return map[module] || module;
};

const formatOperationType = (type: string) => {
  const map: Record<string, string> = {
    INSERT: "新增",
    UPDATE: "修改",
    DELETE: "删除",
    QUERY: "查询",
    AUDIT: "审核",
    LOGIN: "登录",
    LOGOUT: "登出",
  };
  return map[type] || type;
};

const columns = [
  { title: "操作人", dataIndex: "operatorName", key: "operatorName" },
  { title: "角色", dataIndex: "operatorRole", key: "operatorRole" },
  { title: "模块", dataIndex: "module", key: "module" },
  { title: "操作类型", dataIndex: "operationType", key: "operationType" },
  { title: "描述", dataIndex: "operationDesc", key: "operationDesc" },
  { title: "关联ID", dataIndex: "relatedId", key: "relatedId" },
  { title: "IP地址", dataIndex: "ipAddress", key: "ipAddress" },
  { title: "耗时", dataIndex: "executionTime", key: "executionTime" },
  { title: "结果", dataIndex: "operationResult", key: "operationResult" },
  { title: "操作时间", dataIndex: "createdAt", key: "createdAt" },
];

const getOperationTypeColor = (type: string) => {
  const map: Record<string, string> = {
    INSERT: "blue",
    UPDATE: "orange",
    DELETE: "red",
    QUERY: "green",
    AUDIT: "purple",
    LOGIN: "cyan",
    LOGOUT: "magenta",
  };
  return map[type] || "default";
};

const formatDate = (date: string) => {
  return dayjs(date).format("YYYY-MM-DD HH:mm:ss");
};

const formatExecutionTime = (executionTime?: number) => {
  if (executionTime === null || executionTime === undefined) return "-";
  return `${executionTime} ms`;
};

const fetchData = async () => {
  loading.value = true;
  try {
    const params: LogQueryRequest = {
      page: pagination.current,
      size: pagination.pageSize,
      ...queryParams,
    };
    const res: any = isAdmin.value ? await getLogList(params) : await getMyLogList(params);
    dataSource.value = res.records || [];
    pagination.total = res.total || 0;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleSearch = () => {
  pagination.current = 1;
  fetchData();
};

const resetQuery = () => {
  queryParams.operatorName = "";
  queryParams.module = undefined;
  queryParams.operationType = undefined;
  handleSearch();
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchData();
};

onMounted(() => {
  fetchData();
});
</script>
