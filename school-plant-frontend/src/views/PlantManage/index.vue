<template>
  <div>
    <!-- Search Bar -->
    <a-card class="mb-4 shadow-sm" :bordered="false">
      <a-form layout="vertical" :model="queryParams" @finish="handleSearch">
        <a-row :gutter="[16, 16]">
          <a-col :xs="24" :sm="12" :md="6" :lg="6">
            <a-form-item label="植物名称" class="mb-0">
              <a-input
                v-model:value="queryParams.name"
                placeholder="请输入名称"
                allow-clear
              />
            </a-form-item>
          </a-col>
          <a-col :xs="24" :sm="12" :md="6" :lg="6">
            <a-form-item label="品种" class="mb-0">
              <a-select
                v-model:value="queryParams.species"
                placeholder="请选择品种"
                allow-clear
                class="w-full"
              >
                <a-select-option v-for="s in speciesList" :key="s" :value="s">{{
                  s
                }}</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :xs="24" :sm="12" :md="6" :lg="6">
            <a-form-item label="区域" class="mb-0">
              <a-input
                v-model:value="queryParams.region"
                placeholder="请输入区域"
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
                <a-select-option value="AVAILABLE">可认养</a-select-option>
                <a-select-option value="ADOPTED">已认养</a-select-option>
                <a-select-option value="HEALTHY">健康</a-select-option>
                <a-select-option value="SICK">生病</a-select-option>
                <a-select-option value="MAINTENANCE">养护中</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="24" class="text-right">
            <a-space>
              <a-button type="primary" html-type="submit" :loading="loading">
                查询
              </a-button>
              <a-button @click="resetQuery">重置</a-button>
            </a-space>
          </a-col>
        </a-row>
      </a-form>
    </a-card>

    <!-- Table Area -->
    <a-card class="shadow-sm" :bordered="false">
      <div class="mb-4 flex justify-between items-center">
        <div class="text-lg font-bold">植物列表</div>
        <a-button type="primary" @click="handleAdd">
          <template #icon><PlusOutlined /></template>
          新增植物
        </a-button>
      </div>

      <!-- Mobile List View -->
      <div class="md:hidden">
        <div
          v-for="record in dataSource"
          :key="record.id"
          class="bg-white p-4 mb-4 rounded-xl border border-gray-100 shadow-md"
        >
          <div class="flex gap-4">
            <div class="flex-shrink-0">
              <a-image
                :width="100"
                :src="getPlantImage(record)"
                class="rounded-xl object-cover h-24 w-24"
                :fallback="'/images/default-plant.png'"
              />
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex justify-between items-start mb-2">
                <span class="font-bold text-lg text-gray-900 truncate">{{
                  record.name
                }}</span>
                <div>
                  <a-tag
                    :color="getStatusColor(record.healthStatus || 'HEALTHY')"
                    class="mr-1 px-2 py-0.5 rounded-full text-xs"
                  >
                    {{ getStatusLabel(record.healthStatus || "HEALTHY") }}
                  </a-tag>
                  <a-tag
                    :color="getStatusColor(record.status)"
                    class="mr-0 px-2 py-0.5 rounded-full text-xs"
                  >
                    {{ getStatusLabel(record.status) }}
                  </a-tag>
                </div>
              </div>
              <div class="space-y-1">
                <div class="text-xs text-gray-500 flex items-center">
                  <span
                    class="bg-blue-50 text-blue-600 px-1.5 py-0.5 rounded mr-2"
                    >编号</span
                  >
                  {{ record.plantCode }}
                </div>
                <div class="text-xs text-gray-500 flex items-center">
                  <span
                    class="bg-green-50 text-green-600 px-1.5 py-0.5 rounded mr-2"
                    >品种</span
                  >
                  {{ record.species }}
                </div>
                <div class="text-xs text-gray-500 flex items-center">
                  <span
                    class="bg-purple-50 text-purple-600 px-1.5 py-0.5 rounded mr-2"
                    >科属</span
                  >
                  {{ record.family || "未设置" }}
                </div>
              </div>
            </div>
          </div>

          <div
            class="mt-4 grid grid-cols-2 gap-2 text-xs bg-gray-50 p-3 rounded-lg"
          >
            <div>
              <span class="text-gray-400 block mb-0.5">区域</span>
              <span class="text-gray-700 font-medium">{{ record.region }}</span>
            </div>
            <div>
              <span class="text-gray-400 block mb-0.5">位置</span>
              <span class="text-gray-700 font-medium truncate block">{{
                record.locationDescription
              }}</span>
            </div>
            <div>
              <span class="text-gray-400 block mb-0.5">认养人</span>
              <span class="text-gray-700 font-medium">{{
                record.adopterName || "无人认养"
              }}</span>
            </div>
            <div>
              <span class="text-gray-400 block mb-0.5">养护难度</span>
              <a-rate
                :value="record.careDifficulty"
                disabled
                class="text-[10px]"
              />
            </div>
          </div>

          <div class="mt-4 flex justify-end gap-3">
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
        :scroll="{ x: 1500 }"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'imageUrl'">
            <a-image
              v-if="getPlantImage(record)"
              :width="50"
              :src="getPlantImage(record)"
              class="rounded-md object-cover"
              :fallback="'/images/default-plant.png'"
            />
            <a-image
              v-else
              :width="50"
              src="/images/default-plant.png"
              class="rounded-md object-cover"
            />
          </template>
          <template v-else-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ getStatusLabel(record.status) }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'healthStatus'">
            <a-tag :color="getStatusColor(record.healthStatus || 'HEALTHY')">
              {{ getStatusLabel(record.healthStatus || "HEALTHY") }}
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
      width="600px"
    >
      <a-form
        ref="modalFormRef"
        :model="formState"
        layout="vertical"
        :rules="rules"
      >
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="植物图片" name="imageUrls">
              <a-upload
                list-type="picture-card"
                class="avatar-uploader"
                :show-upload-list="false"
                action="/api/common/upload"
                :headers="uploadHeaders"
                @change="handleImageChange"
              >
                <img
                  v-if="formState.imageUrls"
                  :src="formState.imageUrls"
                  alt="avatar"
                  style="width: 100%; height: 100px; object-fit: cover"
                />
                <div v-else>
                  <plus-outlined />
                  <div class="ant-upload-text">上传</div>
                </div>
              </a-upload>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="植物编号" name="plantCode">
              <a-input
                v-model:value="formState.plantCode"
                placeholder="唯一编号"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="植物名称" name="name">
              <a-input v-model:value="formState.name" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="品种 (学名)" name="species">
              <a-input v-model:value="formState.species" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="科属" name="family">
              <a-input v-model:value="formState.family" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="校园区域" name="region">
              <a-input
                v-model:value="formState.region"
                placeholder="如：东校区"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-form-item label="详细位置描述" name="locationDescription">
          <a-input
            v-model:value="formState.locationDescription"
            placeholder="如：图书馆前广场"
          />
        </a-form-item>

        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="种植年份" name="plantingYear">
              <a-input-number
                v-model:value="formState.plantingYear"
                class="w-full"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="养护难度 (1-5)" name="careDifficulty">
              <a-rate v-model:value="formState.careDifficulty" :count="5" />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="健康状态" name="healthStatus">
              <a-select v-model:value="formState.healthStatus">
                <a-select-option value="HEALTHY">健康</a-select-option>
                <a-select-option value="SICK">生病</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16" v-if="formState.id">
          <a-col :span="12">
            <a-form-item label="认养状态" name="status">
              <a-select v-model:value="formState.status">
                <a-select-option value="AVAILABLE">可认养</a-select-option>
                <a-select-option value="ADOPTED">已认养</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="光照需求" name="lightRequirement">
              <a-select v-model:value="formState.lightRequirement">
                <a-select-option value="全日照">全日照</a-select-option>
                <a-select-option value="半日照">半日照</a-select-option>
                <a-select-option value="半阴">半阴</a-select-option>
                <a-select-option value="全阴">全阴</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="水分需求" name="waterRequirement">
              <a-select v-model:value="formState.waterRequirement">
                <a-select-option value="高">高</a-select-option>
                <a-select-option value="中">中</a-select-option>
                <a-select-option value="低">低</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="生长周期" name="growthCycle">
              <a-input
                v-model:value="formState.growthCycle"
                placeholder="如：春季开花"
              />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="养护要点" name="careTips">
              <a-input
                v-model:value="formState.careTips"
                placeholder="简要养护说明"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-form-item label="描述" name="description">
          <a-textarea v-model:value="formState.description" :rows="3" />
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
} from "@ant-design/icons-vue";
import { message } from "ant-design-vue";
import type { UploadChangeParam } from "ant-design-vue";
import {
  getPlantList,
  getPlantSpecies,
  addPlant,
  updatePlant,
  deletePlant,
  type PlantVO,
  type PlantQueryRequest,
} from "@/api/plant";

// --- State ---
const loading = ref(false);
const dataSource = ref<PlantVO[]>([]);
const speciesList = ref<string[]>([]);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
});

const token = localStorage.getItem("token");
const uploadHeaders = token ? { satoken: token } : {};

const queryParams = reactive<PlantQueryRequest>({
  name: undefined,
  species: undefined,
  status: undefined,
  region: "",
});

// --- Modal State ---
const modalVisible = ref(false);
const modalTitle = ref("新增植物");
const modalLoading = ref(false);
const modalFormRef = ref();
const formState = reactive<any>({
  id: undefined,
  plantCode: "",
  name: "",
  species: "",
  family: "",
  locationDescription: "",
  region: "",
  careDifficulty: 1,
  plantingYear: new Date().getFullYear(),
  status: "AVAILABLE",
  healthStatus: "HEALTHY",
  description: "",
  imageUrls: "",
  lightRequirement: undefined,
  waterRequirement: undefined,
  careTips: "",
  growthCycle: "",
});

const rules = {
  plantCode: [{ required: true, message: "请输入编号" }],
  name: [{ required: true, message: "请输入名称" }],
  species: [{ required: true, message: "请输入品种" }],
  locationDescription: [{ required: true, message: "请输入位置描述" }],
  plantingYear: [{ required: true, message: "请输入年份" }],
};

const columns = [
  { title: "ID", dataIndex: "id", width: 60, fixed: "left" },
  { title: "图片", key: "imageUrl", width: 80, fixed: "left" },
  { title: "编号", dataIndex: "plantCode", width: 120, ellipsis: true },
  { title: "名称", dataIndex: "name", width: 150, ellipsis: true },
  { title: "品种", dataIndex: "species", width: 120, ellipsis: true },
  { title: "科属", dataIndex: "family", width: 120, ellipsis: true },
  { title: "区域", dataIndex: "region", width: 120, ellipsis: true },
  {
    title: "位置",
    dataIndex: "locationDescription",
    width: 200,
    ellipsis: true,
  },
  { title: "难度", dataIndex: "careDifficulty", width: 100 },
  { title: "年份", dataIndex: "plantingYear", width: 80 },
  {
    title: "健康状态",
    dataIndex: "healthStatus",
    key: "healthStatus",
    width: 100,
  },
  { title: "认养状态", dataIndex: "status", key: "status", width: 100 },
  { title: "发布人", dataIndex: "userRealName", width: 100 },
  { title: "联系电话", dataIndex: "userPhone", width: 120 },
  { title: "认养人", dataIndex: "adopterName", width: 100, ellipsis: true },
  { title: "操作", key: "action", width: 120, fixed: "right" },
];

// --- Methods ---

const getStatusColor = (status: string) => {
  const map: any = {
    HEALTHY: "green",
    SICK: "red",
    MAINTENANCE: "orange",
    ADOPTED: "blue",
    AVAILABLE: "cyan",
  };
  return map[status] || "default";
};

const getStatusLabel = (status: string) => {
  const map: any = {
    HEALTHY: "健康",
    SICK: "生病",
    MAINTENANCE: "养护中",
    ADOPTED: "已认养",
    AVAILABLE: "可认养",
  };
  return map[status] || status;
};

const getPlantImage = (plant: PlantVO) => {
  if (plant.imageUrls) {
    try {
      const parsed = JSON.parse(plant.imageUrls);
      if (Array.isArray(parsed) && parsed.length > 0) {
        return parsed[0];
      }
      if (typeof parsed === "string" && parsed.startsWith("http")) {
        return parsed;
      }
    } catch (e) {
      if (
        typeof plant.imageUrls === "string" &&
        plant.imageUrls.startsWith("http")
      ) {
        return plant.imageUrls;
      }
    }
  }
  return "/images/default-plant.png";
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res: any = await getPlantList({
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

const fetchSpecies = async () => {
  try {
    const res = await getPlantSpecies();
    speciesList.value = res;
  } catch (e) {}
};

const handleSearch = () => {
  pagination.current = 1;
  fetchData();
};

const resetQuery = () => {
  queryParams.name = undefined;
  queryParams.species = undefined;
  queryParams.status = undefined;
  queryParams.region = "";
  handleSearch();
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchData();
};

const handleAdd = () => {
  modalTitle.value = "新增植物";
  formState.id = undefined;
  formState.plantCode = "";
  formState.name = "";
  formState.species = "";
  formState.family = "";
  formState.locationDescription = "";
  formState.region = "";
  formState.careDifficulty = 1;
  formState.plantingYear = new Date().getFullYear();
  formState.status = "AVAILABLE";
  formState.healthStatus = "HEALTHY";
  formState.description = "";
  formState.imageUrls = "";
  formState.lightRequirement = undefined;
  formState.waterRequirement = undefined;
  formState.careTips = "";
  formState.growthCycle = "";
  modalVisible.value = true;
};

const handleEdit = (record: PlantVO) => {
  modalTitle.value = "编辑植物";
  Object.assign(formState, record);
  formState.imageUrls = getPlantImage(record);

  // Ensure careTips and growthCycle are populated if they exist in record (even if not in VO type explicitly before)
  if ((record as any).careTips) formState.careTips = (record as any).careTips;
  if ((record as any).growthCycle)
    formState.growthCycle = (record as any).growthCycle;

  modalVisible.value = true;
};

const handleDelete = async (id: number) => {
  try {
    await deletePlant([id]);
    message.success("删除成功");
    fetchData();
  } catch (error) {}
};

const handleImageChange = (info: UploadChangeParam) => {
  if (info.file.status === "done") {
    const response: any = info.file.response;
    if (response && response.code === 200) {
      formState.imageUrls = response.data.url;
      message.success("图片上传成功");
    } else {
      message.error(response?.msg || "上传失败");
    }
  } else if (info.file.status === "error") {
    message.error("图片上传失败");
  }
};

const handleModalOk = async () => {
  try {
    await modalFormRef.value.validate();
    modalLoading.value = true;
    if (formState.id) {
      await updatePlant(formState);
      message.success("更新成功");
    } else {
      await addPlant(formState);
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
  fetchSpecies();
});
</script>
