<template>
  <div>
    <!-- Search Bar -->
    <a-card class="mb-4 shadow-sm" :bordered="false">
      <a-form layout="vertical" :model="queryParams" @finish="handleSearch">
        <a-row :gutter="[16, 16]">
          <a-col :xs="24" :sm="12" :md="6" :lg="6">
            <a-form-item label="用户ID" class="mb-0">
              <a-input-number
                v-model:value="queryParams.id"
                placeholder="请输入用户ID"
                allow-clear
                class="w-full"
              />
            </a-form-item>
          </a-col>
          <a-col :xs="24" :sm="12" :md="6" :lg="6">
            <a-form-item label="用户名" class="mb-0">
              <a-input
                v-model:value="queryParams.username"
                placeholder="请输入用户名"
                allow-clear
              />
            </a-form-item>
          </a-col>
          <a-col :xs="24" :sm="12" :md="6" :lg="6">
            <a-form-item label="真实姓名" class="mb-0">
              <a-input
                v-model:value="queryParams.realName"
                placeholder="请输入真实姓名"
                allow-clear
              />
            </a-form-item>
          </a-col>
          <a-col :xs="24" :sm="12" :md="6" :lg="6">
            <a-form-item label="状态" class="mb-0">
              <a-select
                v-model:value="queryParams.status"
                placeholder="选择状态"
                allow-clear
                class="w-full"
              >
                <a-select-option :value="1">正常</a-select-option>
                <a-select-option :value="0">禁用</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="24" class="text-right">
            <a-space>
              <a-button type="primary" html-type="submit" :loading="loading"
                >查询</a-button
              >
              <a-button @click="resetQuery">重置</a-button>
            </a-space>
          </a-col>
        </a-row>
      </a-form>
    </a-card>

    <!-- Table Area -->
    <a-card class="shadow-sm" :bordered="false">
      <div class="mb-4 flex justify-between items-center">
        <div class="text-lg font-bold">用户列表</div>
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新增用户
        </a-button>
      </div>

      <!-- Mobile List View -->
      <div class="md:hidden">
        <div
          v-for="record in dataSource"
          :key="record.id"
          class="bg-white p-4 mb-4 rounded-xl border border-gray-100 shadow-md"
        >
          <div class="flex justify-between items-center mb-4">
            <div class="flex items-center gap-2">
              <div
                class="w-10 h-10 bg-blue-50 rounded-full flex items-center justify-center text-blue-500"
              >
                <UserOutlined class="text-xl" />
              </div>
              <div>
                <div class="font-bold text-gray-900 text-base">
                  {{ record.username }}
                </div>
                <div class="text-xs text-gray-400">ID: {{ record.id }}</div>
              </div>
            </div>
            <a-tag
              :color="record.status === 1 ? 'green' : 'red'"
              class="rounded-full px-3"
            >
              {{ record.status === 1 ? "正常" : "禁用" }}
            </a-tag>
          </div>

          <div class="space-y-2 bg-gray-50 p-3 rounded-lg mb-4">
            <div class="flex items-center text-sm text-gray-600">
              <span class="w-16 text-gray-400">姓名</span>
              <span class="font-medium text-gray-800">{{
                record.realName
              }}</span>
            </div>
            <div class="flex items-center text-sm text-gray-600">
              <span class="w-16 text-gray-400">手机</span>
              <span class="font-medium text-gray-800">{{
                record.phone || "暂无"
              }}</span>
            </div>
            <div class="flex items-center text-sm text-gray-600">
              <span class="w-16 text-gray-400">邮箱</span>
              <span class="font-medium text-gray-800 truncate">{{
                record.email || "暂无"
              }}</span>
            </div>
          </div>

          <div class="flex justify-end gap-3">
            <a-button
              type="dashed"
              size="middle"
              class="rounded-lg"
              @click="handleEdit(record)"
            >
              <template #icon><EditOutlined /></template>
              编辑
            </a-button>
            <a-popconfirm
              title="确定要删除吗?"
              @confirm="handleDelete(record.id)"
              ok-text="确定"
              cancel-text="取消"
            >
              <a-button
                type="primary"
                danger
                ghost
                size="middle"
                class="rounded-lg"
              >
                <template #icon><DeleteOutlined /></template>
                删除
              </a-button>
            </a-popconfirm>
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
        :scroll="{ x: 1000 }"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="record.status === 1 ? 'green' : 'red'">
              {{ record.status === 1 ? "正常" : "禁用" }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a @click="handleEdit(record)">编辑</a>
              <a-popconfirm
                title="确定要删除吗?"
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

    <!-- Add/Edit Modal -->
    <a-modal
      v-model:open="modalVisible"
      :title="modalTitle"
      @ok="handleModalOk"
      :confirmLoading="modalLoading"
      okText="确定"
      cancelText="取消"
    >
      <a-form
        ref="modalFormRef"
        :model="formState"
        layout="vertical"
        :rules="rules"
      >
        <a-form-item label="用户名" name="username">
          <a-input
            v-model:value="formState.username"
            :disabled="!!formState.id"
          />
        </a-form-item>
        <a-form-item label="真实姓名" name="realName">
          <a-input v-model:value="formState.realName" />
        </a-form-item>
        <a-form-item label="密码" name="password" v-if="!formState.id">
          <a-input-password
            v-model:value="formState.password"
            placeholder="默认 123456"
          />
        </a-form-item>
        <a-form-item label="手机号" name="phone">
          <a-input v-model:value="formState.phone" />
        </a-form-item>
        <a-form-item label="邮箱" name="email">
          <a-input v-model:value="formState.email" />
        </a-form-item>
        <a-form-item label="角色" name="roleId">
          <a-select v-model:value="formState.roleId" placeholder="请选择角色">
            <a-select-option
              v-for="role in roleList"
              :key="role.id"
              :value="role.id"
            >
              {{ role.roleName }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="状态" name="status">
          <a-radio-group v-model:value="formState.status">
            <a-radio :value="1">正常</a-radio>
            <a-radio :value="0">禁用</a-radio>
          </a-radio-group>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import {
  PlusOutlined,
  EditOutlined,
  DeleteOutlined,
  UserOutlined,
  PhoneOutlined,
  MailOutlined,
} from "@ant-design/icons-vue";
import { message } from "ant-design-vue";
import {
  getUserList,
  addUser,
  updateUser,
  deleteUser,
  getRoleList,
  type UserVO,
  type UserQueryRequest,
  type RoleVO,
} from "@/api/user-manage";

// --- State ---
const loading = ref(false);
const dataSource = ref<UserVO[]>([]);
const roleList = ref<RoleVO[]>([]);
const currentUsername = localStorage.getItem("username"); // Get current logged-in user
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
});

const queryParams = reactive<UserQueryRequest>({
  username: "",
  realName: "",
  status: undefined,
});

// --- Modal State ---
const modalVisible = ref(false);
const modalTitle = ref("新增用户");
const modalLoading = ref(false);
const modalFormRef = ref();
const formState = reactive<any>({
  id: undefined,
  username: "",
  realName: "",
  password: "",
  phone: "",
  email: "",
  roleId: undefined,
  status: 1,
});

const rules = {
  username: [{ required: true, message: "请输入用户名" }],
  realName: [{ required: true, message: "请输入真实姓名" }],
  roleId: [{ required: true, message: "请选择角色" }],
};

const columns = [
  { title: "ID", dataIndex: "id", width: 60, fixed: "left" },
  { title: "用户名", dataIndex: "username", width: 120, ellipsis: true },
  { title: "真实姓名", dataIndex: "realName", width: 120, ellipsis: true },
  { title: "手机号", dataIndex: "phone", width: 120 },
  { title: "邮箱", dataIndex: "email", width: 180, ellipsis: true },
  { title: "状态", key: "status", width: 100 },
  { title: "创建时间", dataIndex: "createdAt", width: 180 },
  { title: "操作", key: "action", width: 150, fixed: "right" },
];

// --- Methods ---

const fetchData = async () => {
  loading.value = true;
  try {
    const res: any = await getUserList({
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

const fetchRoles = async () => {
  try {
    const res: any = await getRoleList();
    roleList.value = res.records || [];
  } catch (e) {}
};

const handleSearch = () => {
  pagination.current = 1;
  fetchData();
};

const resetQuery = () => {
  queryParams.id = undefined;
  queryParams.username = "";
  queryParams.realName = "";
  queryParams.status = undefined;
  handleSearch();
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchData();
};

const handleAdd = () => {
  modalTitle.value = "新增用户";
  formState.id = undefined;
  formState.username = "";
  formState.realName = "";
  formState.password = "123456";
  formState.phone = "";
  formState.email = "";
  formState.roleId = undefined;
  formState.status = 1;
  modalVisible.value = true;
};

const handleEdit = (record: UserVO) => {
  modalTitle.value = "编辑用户";
  Object.assign(formState, record);
  // Password not needed for edit
  formState.password = undefined;
  modalVisible.value = true;
};

const handleDelete = async (id: number) => {
  try {
    await deleteUser([id]);
    message.success("删除成功");
    fetchData();
  } catch (error) {}
};

const handleModalOk = async () => {
  try {
    await modalFormRef.value.validate();
    modalLoading.value = true;
    if (formState.id) {
      await updateUser(formState);
      message.success("更新成功");
    } else {
      await addUser(formState);
      message.success("新增成功");
    }
    modalVisible.value = false;
    fetchData();
  } catch (error) {
    console.error(error);
  } finally {
    modalLoading.value = false;
  }
};

onMounted(() => {
  fetchData();
  fetchRoles();
});
</script>
