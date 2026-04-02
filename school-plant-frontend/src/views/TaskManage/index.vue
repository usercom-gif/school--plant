<template>
  <div>
    <!-- Search Bar -->
    <a-card class="mb-4 shadow-sm" :bordered="false">
      <a-form layout="inline" :model="queryParams" @finish="handleSearch">
        <a-form-item label="状态">
          <a-select
            v-model:value="queryParams.status"
            placeholder="任务状态"
            style="width: 120px"
            allow-clear
          >
            <a-select-option value="PENDING">待完成</a-select-option>
            <a-select-option value="COMPLETED">已完成</a-select-option>
            <a-select-option value="OVERDUE">已逾期</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item>
          <a-button type="primary" html-type="submit" :loading="loading"
            >查询</a-button
          >
          <a-button class="ml-2" @click="resetQuery">重置</a-button>
          <a-button
            v-if="isAdmin"
            class="ml-2"
            @click="handleCreate"
            type="primary"
            ghost
            >新建任务</a-button
          >
        </a-form-item>
      </a-form>
    </a-card>

    <!-- Table Area -->
    <a-card class="shadow-sm" :bordered="false">
      <div class="mb-4 flex justify-between items-center">
        <div class="text-lg font-bold">养护任务管理</div>
      </div>

      <!-- Mobile List View -->
      <div class="md:hidden">
        <div
          v-for="record in dataSource"
          :key="record.id"
          class="bg-white p-4 mb-3 rounded-lg border border-gray-100 shadow-sm"
        >
          <div class="flex justify-between items-start mb-2">
            <span class="font-medium text-gray-900"
              >#{{ record.id }} {{ record.taskType }}</span
            >
            <a-tag :color="getStatusColor(record.status)" class="mr-0">
              {{ getStatusLabel(record.status) }}
            </a-tag>
          </div>

          <div class="text-sm text-gray-500 mb-1">
            <span class="mr-2">植物: {{ record.plantName }}</span>
            <span>执行人: {{ record.userName }}</span>
          </div>

          <div class="text-sm text-gray-600 mb-2 line-clamp-2">
            {{ record.taskDescription }}
          </div>

          <div class="flex justify-between items-center text-sm">
            <span class="text-gray-400">截止: {{ record.dueDate }}</span>
            <a-space v-if="isAdmin">
              <a @click="handleEdit(record)" class="text-blue-600">编辑</a>
              <a-divider type="vertical" />
              <a-popconfirm
                title="确定删除该任务吗？"
                @confirm="handleDelete(record.id)"
                ok-text="确定"
                cancel-text="取消"
              >
                <a class="text-red-500">删除</a>
              </a-popconfirm>
            </a-space>
          </div>
        </div>

        <!-- Mobile Pagination -->
        <div class="flex justify-center mt-4" v-if="dataSource.length > 0">
          <a-pagination
            v-model:current="pagination.current"
            :total="pagination.total"
            :pageSize="pagination.pageSize"
            @change="
              (page) =>
                handleTableChange({
                  current: page,
                  pageSize: pagination.pageSize,
                })
            "
            simple
          />
        </div>
      </div>

      <!-- Desktop Table View -->
      <a-table
        class="hidden md:block"
        :columns="columns"
        :data-source="dataSource"
        :loading="loading"
        :pagination="pagination"
        @change="handleTableChange"
        row-key="id"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ getStatusLabel(record.status) }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space v-if="isAdmin">
              <a @click="handleEdit(record)">编辑</a>
              <a-divider type="vertical" />
              <a-popconfirm
                title="确定删除该任务吗？"
                @confirm="handleDelete(record.id)"
                ok-text="确定"
                cancel-text="取消"
              >
                <a class="text-red-500">删除</a>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- Edit/Create Modal -->
    <a-modal
      v-model:open="modalVisible"
      :title="isEdit ? '编辑任务' : '新建任务'"
      @ok="handleModalSubmit"
      :confirmLoading="modalLoading"
    >
      <a-form layout="vertical" ref="formRef" :model="formState" :rules="rules">
        <!-- Ideally populate users and plants from API -->
        <a-form-item label="关联植物ID" name="plantId">
          <a-input-number
            v-model:value="formState.plantId"
            class="w-full"
            placeholder="输入植物ID"
          />
        </a-form-item>
        <a-form-item label="指派用户ID" name="userId">
          <a-input-number
            v-model:value="formState.userId"
            class="w-full"
            placeholder="输入用户ID"
          />
        </a-form-item>
        <a-form-item label="任务类型" name="taskType">
          <a-select v-model:value="formState.taskType" placeholder="选择类型">
            <a-select-option value="浇水">浇水</a-select-option>
            <a-select-option value="施肥">施肥</a-select-option>
            <a-select-option value="修剪">修剪</a-select-option>
            <a-select-option value="除虫">除虫</a-select-option>
            <a-select-option value="其他">其他</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="任务描述" name="taskDescription">
          <a-textarea v-model:value="formState.taskDescription" :rows="3" />
        </a-form-item>
        <a-form-item label="截止日期" name="dueDate">
          <!-- Simplified date input, ideally use a-date-picker with value-format="YYYY-MM-DD" -->
          <a-input v-model:value="formState.dueDate" placeholder="YYYY-MM-DD" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted, computed } from "vue";
import { message } from "ant-design-vue";
import {
  getTaskList,
  createTask,
  updateTask,
  deleteTask,
  type CareTask,
  type TaskQueryRequest,
} from "@/api/task";

const loading = ref(false);
const dataSource = ref<CareTask[]>([]);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

const queryParams = reactive<TaskQueryRequest>({});

const role = ref(localStorage.getItem("role") || "USER");
const isAdmin = computed(() => role.value === "ADMIN");

// Modal State
const modalVisible = ref(false);
const modalLoading = ref(false);
const isEdit = ref(false);
const formRef = ref();
const formState = reactive<Partial<CareTask>>({});

const rules = {
  plantId: [{ required: true, message: "请输入植物ID" }],
  userId: [{ required: true, message: "请输入用户ID" }],
  taskType: [{ required: true, message: "请选择任务类型" }],
  taskDescription: [{ required: true, message: "请输入描述" }],
  dueDate: [{ required: true, message: "请输入截止日期" }],
};

const columns = computed(() => {
  const base = [
    { title: "ID", dataIndex: "id", width: 60 },
    { title: "植物", dataIndex: "plantName" },
    { title: "执行人", dataIndex: "userName" },
    { title: "类型", dataIndex: "taskType", width: 80 },
    { title: "描述", dataIndex: "taskDescription", ellipsis: true },
    { title: "截止日期", dataIndex: "dueDate", width: 120 },
    { title: "状态", key: "status", width: 100 },
  ];
  if (isAdmin.value) {
    return [...base, { title: "操作", key: "action", width: 150 }];
  }
  return base;
});

const getStatusColor = (status: string) => {
  const map: any = { PENDING: "orange", COMPLETED: "green", OVERDUE: "red" };
  return map[status] || "default";
};

const getStatusLabel = (status: string) => {
  const map: any = {
    PENDING: "待完成",
    COMPLETED: "已完成",
    OVERDUE: "已逾期",
  };
  return map[status] || status;
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res: any = await getTaskList({
      page: pagination.current,
      size: pagination.pageSize,
      ...queryParams,
    });
    dataSource.value = res.records;
    pagination.total = res.total;
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
  queryParams.status = undefined;
  handleSearch();
};

const handleCreate = () => {
  if (!isAdmin.value) {
    message.error("无权限操作");
    return;
  }
  isEdit.value = false;
  Object.keys(formState).forEach((key) => delete (formState as any)[key]);
  modalVisible.value = true;
};

const handleEdit = (record: CareTask) => {
  if (!isAdmin.value) {
    message.error("无权限操作");
    return;
  }
  isEdit.value = true;
  Object.assign(formState, record);
  modalVisible.value = true;
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchData();
};

const handleDelete = async (id: number) => {
  if (!isAdmin.value) {
    message.error("无权限操作");
    return;
  }
  try {
    await deleteTask([id]);
    message.success("删除成功");
    fetchData();
  } catch (e) {
    console.error(e);
  }
};

const handleModalSubmit = async () => {
  if (!isAdmin.value) {
    message.error("无权限操作");
    return;
  }
  try {
    await formRef.value.validate();
    modalLoading.value = true;
    if (isEdit.value) {
      await updateTask(formState);
    } else {
      await createTask(formState);
    }
    message.success(isEdit.value ? "更新成功" : "创建成功");
    modalVisible.value = false;
    fetchData();
  } catch (e) {
    console.error(e);
  } finally {
    modalLoading.value = false;
  }
};

onMounted(() => {
  fetchData();
});
</script>
