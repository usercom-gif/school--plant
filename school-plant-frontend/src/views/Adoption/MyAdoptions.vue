<template>
  <div class="space-y-6">
    <a-card class="shadow-sm rounded-lg" :bordered="false">
      <div class="flex justify-between items-center mb-6">
        <div>
          <h2 class="text-xl font-bold text-gray-800">我的认养植物</h2>
          <p class="text-gray-500 text-sm">
            这里展示您当前正在认养和已结束认养的植物记录
          </p>
        </div>
        <a-button type="primary" @click="router.push('/user/plant-search')">
          <template #icon><SearchOutlined /></template>
          认养更多植物
        </a-button>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="py-20 text-center">
        <a-spin size="large" />
      </div>

      <!-- Empty State -->
      <div v-else-if="dataSource.length === 0" class="py-16 text-center">
        <a-empty description="暂无认养记录">
          <a-button type="primary" @click="router.push('/user/plant-search')"
            >去看看校园植物</a-button
          >
        </a-empty>
      </div>

      <!-- Records List -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <a-card
          v-for="record in dataSource"
          :key="record.id"
          hoverable
          class="overflow-hidden border-0 shadow-sm hover:shadow-md transition-all rounded-xl"
          :body-style="{ padding: 0 }"
        >
          <div class="relative h-48 bg-gray-100">
            <!-- Plant Image -->
            <img
              :src="getPlantImage(record)"
              class="w-full h-full object-cover"
              :alt="record.plantName"
            />
            <div class="absolute top-3 right-3">
              <a-tag
                :color="getStatusColor(record.status)"
                class="m-0 shadow-sm border-0 px-3 py-1 rounded-full"
              >
                {{ getStatusLabel(record.status) }}
              </a-tag>
            </div>
          </div>

          <div class="p-5">
            <div class="flex justify-between items-start mb-3">
              <div>
                <h3 class="text-lg font-bold text-gray-800 mb-1">
                  {{ record.plantName }}
                </h3>
                <span
                  class="text-xs text-gray-400 font-mono bg-gray-50 px-2 py-0.5 rounded border border-gray-100"
                >
                  {{ record.plantCode }}
                </span>
              </div>
            </div>

            <div class="space-y-2 mb-6">
              <div class="flex items-center text-sm text-gray-600">
                <CalendarOutlined class="mr-2 text-green-500" />
                <span class="w-20">认养日期:</span>
                <span class="font-medium text-gray-800">{{
                  record.startDate
                }}</span>
              </div>
              <div
                v-if="record.endDate"
                class="flex items-center text-sm text-gray-600"
              >
                <CarryOutOutlined class="mr-2 text-orange-500" />
                <span class="w-20">结束日期:</span>
                <span class="font-medium text-gray-800">{{
                  record.endDate
                }}</span>
              </div>
              <div v-else class="flex items-center text-sm text-gray-600">
                <ClockCircleOutlined class="mr-2 text-blue-500" />
                <span class="w-20">状态说明:</span>
                <span class="font-medium text-green-600">正在认养中</span>
              </div>
            </div>

            <div class="flex gap-2">
              <a-button
                v-if="record.status === 'ACTIVE'"
                type="primary"
                ghost
                block
                size="small"
                @click="handleReport(record)"
              >
                <template #icon><WarningOutlined /></template>
                异常上报
              </a-button>
              <a-button
                v-if="record.status === 'ACTIVE'"
                type="primary"
                block
                size="small"
                @click="handleTask(record)"
              >
                <template #icon><CheckCircleOutlined /></template>
                养护打卡
              </a-button>
              <a-button
                v-if="record.status === 'ACTIVE'"
                type="primary"
                danger
                ghost
                block
                size="small"
                @click="handleFinish(record)"
              >
                <template #icon><CarryOutOutlined /></template>
                提交成果
              </a-button>
              <a-button
                v-if="record.status === 'FINISHED'"
                type="default"
                block
                size="small"
                @click="router.push('/user/my-achievements')"
              >
                查看成果评价
              </a-button>
            </div>
          </div>
        </a-card>
      </div>

      <!-- Pagination -->
      <div
        v-if="pagination.total > pagination.pageSize"
        class="mt-8 flex justify-center"
      >
        <a-pagination
          v-model:current="pagination.current"
          :total="pagination.total"
          :pageSize="pagination.pageSize"
          @change="fetchData"
          show-less-items
        />
      </div>
    </a-card>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import { useRouter } from "vue-router";
import {
  CalendarOutlined,
  ClockCircleOutlined,
  CheckCircleOutlined,
  WarningOutlined,
  SearchOutlined,
  CarryOutOutlined,
} from "@ant-design/icons-vue";
import { getMyAdoptions, finishAdoption } from "@/api/adoption";
import { message, Modal } from "ant-design-vue";

const router = useRouter();
const loading = ref(false);
const dataSource = ref<any[]>([]);

const pagination = reactive({
  current: 1,
  pageSize: 9,
  total: 0,
});

const getStatusColor = (status: string) => {
  const map: any = {
    ACTIVE: "green",
    FINISHED: "blue",
    CANCELLED: "red",
  };
  return map[status] || "default";
};

const getStatusLabel = (status: string) => {
  const map: any = {
    ACTIVE: "认养中",
    FINISHED: "已结束",
    CANCELLED: "已取消",
  };
  return map[status] || status;
};

const getPlantImage = (record: any) => {
  if (record.imageUrls) {
    try {
      const parsed = JSON.parse(record.imageUrls);
      if (Array.isArray(parsed) && parsed.length > 0) {
        return parsed[0];
      } else if (typeof parsed === "string" && parsed.startsWith("http")) {
        return parsed;
      }
    } catch (e) {
      if (
        typeof record.imageUrls === "string" &&
        record.imageUrls.startsWith("http")
      ) {
        return record.imageUrls;
      }
    }
  }
  return "/images/default-plant.png";
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res: any = await getMyAdoptions({
      page: pagination.current,
      size: pagination.pageSize,
    });
    dataSource.value = res.records;
    pagination.total = res.total;
  } catch (error) {
    console.error("Failed to fetch my adoptions:", error);
  } finally {
    loading.value = false;
  }
};

const handleReport = (record: any) => {
  router.push({
    path: "/user/abnormality-report",
    query: { plantId: record.plantId },
  });
};

const handleTask = (record: any) => {
  router.push("/user/my-tasks");
};

const handleFinish = (record: any) => {
  Modal.confirm({
    title: "提交认养成果并结束认养",
    content: `确定要结束对植物《${record.plantName}》的认养吗？系统将根据您的养护打卡率和植物健康状况生成最终评价。结束后该植物将重新开放认养。`,
    okText: "确认提交",
    cancelText: "取消",
    onOk: async () => {
      try {
        await finishAdoption(record.id);
        message.success("认养成果提交成功！");
        fetchData();
      } catch (e: any) {
        message.error(e.message || "提交失败");
      }
    },
  });
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
