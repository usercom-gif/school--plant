<template>
  <a-layout style="height: 100vh; overflow: hidden">
    <!-- Desktop Sider -->
    <a-layout-sider
      v-if="!isMobile"
      v-model:collapsed="collapsed"
      :trigger="null"
      collapsible
      theme="light"
      class="shadow-md z-10"
      width="220"
      style="height: 100vh; overflow: hidden"
    >
      <div
        class="h-16 flex items-center justify-center border-b border-gray-100 flex-shrink-0"
      >
        <div
          class="font-bold text-green-600 transition-all duration-300"
          :class="collapsed ? 'text-xl' : 'text-lg'"
        >
          {{ collapsed ? "SP" : "School Plant" }}
        </div>
      </div>
      <div style="flex: 1; overflow-y: auto; height: calc(100vh - 64px)">
        <a-menu
          v-model:selectedKeys="selectedKeys"
          v-model:openKeys="openKeys"
          theme="light"
          mode="inline"
          @click="handleMenuClick"
          :items="menuItems"
        >
        </a-menu>
      </div>
    </a-layout-sider>

    <!-- Mobile Drawer -->
    <a-drawer
      v-else
      v-model:open="drawerVisible"
      placement="left"
      :closable="false"
      :bodyStyle="{ padding: 0 }"
      width="220"
    >
      <div
        class="h-16 flex items-center justify-center border-b border-gray-100"
      >
        <div class="font-bold text-green-600 text-lg">School Plant</div>
      </div>
      <a-menu
        v-model:selectedKeys="selectedKeys"
        v-model:openKeys="openKeys"
        theme="light"
        mode="inline"
        @click="handleMenuClick"
        :items="menuItems"
        class="h-full border-r-0"
      >
      </a-menu>
    </a-drawer>

    <a-layout
      style="
        display: flex;
        flex-direction: column;
        height: 100vh;
        overflow: hidden;
      "
    >
      <a-layout-header
        style="background: #fff; padding: 0"
        class="flex justify-between items-center px-4 md:px-6 shadow-sm z-10 flex-shrink-0 h-16"
      >
        <component
          :is="
            isMobile
              ? MenuUnfoldOutlined
              : collapsed
                ? MenuUnfoldOutlined
                : MenuFoldOutlined
          "
          class="trigger"
          @click="toggleMenu"
        />

        <div class="flex items-center gap-2 md:gap-4">
          <!-- Publish Announcement Button (Admin Only) -->
          <a-button
            v-if="localStorage.getItem('userRole') === 'ADMIN'"
            type="primary"
            shape="round"
            class="hidden md:inline-flex bg-gradient-to-r from-blue-500 to-indigo-600 border-none hover:shadow-md transition-all"
            @click="announcementVisible = true"
          >
            发布系统公告
          </a-button>

          <!-- Notification Bell -->
          <a-popover
            v-model:open="notificationVisible"
            trigger="click"
            placement="bottomRight"
            overlayClassName="notification-popover"
            :arrowPointAtCenter="true"
          >
            <template #content>
              <div class="w-80">
                <div
                  class="flex justify-between items-center px-4 py-3 border-b border-gray-100"
                >
                  <span class="font-bold text-gray-700">消息通知</span>
                  <a-tooltip title="全部标为已读">
                    <CheckOutlined
                      class="text-gray-400 hover:text-green-600 cursor-pointer"
                      @click="handleMarkAllRead"
                    />
                  </a-tooltip>
                </div>
                <div class="max-h-96 overflow-y-auto">
                  <a-list
                    :loading="notificationLoading"
                    item-layout="horizontal"
                    :data-source="notifications"
                  >
                    <template #renderItem="{ item }">
                      <a-list-item
                        class="px-4 py-3 hover:bg-gray-50 transition-colors cursor-pointer border-b border-gray-50"
                        :class="{ 'bg-blue-50': item.isRead === 0 }"
                        @click="handleViewNotification(item)"
                      >
                        <a-list-item-meta
                          :description="
                            item.content.length > 20
                              ? item.content.substring(0, 20) + '...'
                              : item.content
                          "
                        >
                          <template #title>
                            <div class="flex justify-between items-start">
                              <span class="font-medium text-sm">{{
                                item.title
                              }}</span>
                              <span class="text-xs text-gray-400">{{
                                new Date(item.createdAt).toLocaleDateString()
                              }}</span>
                            </div>
                          </template>
                          <template #avatar>
                            <div
                              class="w-2 h-2 rounded-full mt-2"
                              :class="
                                item.isRead === 0
                                  ? 'bg-blue-500'
                                  : 'bg-transparent'
                              "
                            ></div>
                          </template>
                        </a-list-item-meta>
                      </a-list-item>
                    </template>
                    <template #empty>
                      <div class="py-8 text-center text-gray-400">
                        <BellOutlined class="text-2xl mb-2" />
                        <p>暂无新通知</p>
                      </div>
                    </template>
                  </a-list>
                </div>
                <div
                  class="px-4 py-2 border-t border-gray-100 text-center text-xs text-gray-400"
                >
                  显示最近 10 条消息
                </div>
              </div>
            </template>
            <div
              class="cursor-pointer hover:bg-gray-50 p-2 rounded-full transition-colors relative"
              @click="handleNotificationClick"
            >
              <a-badge :count="unreadNotificationCount" :offset="[-2, 2]">
                <BellOutlined class="text-xl text-gray-600" />
              </a-badge>
            </div>
          </a-popover>

          <span class="text-gray-500 hidden md:inline"
            >欢迎回来, {{ username }}</span
          >
          <a-dropdown>
            <div
              class="flex items-center gap-2 cursor-pointer hover:bg-gray-50 px-3 py-1 rounded-full transition-colors"
            >
              <a-avatar
                :src="avatarUrl || '/images/default-avatar.png'"
                style="background-color: #87d068"
              >
                <template #icon><UserOutlined /></template>
              </a-avatar>
              <span class="font-medium text-gray-700 md:inline hidden">{{
                username
              }}</span>
            </div>
            <template #overlay>
              <a-menu>
                <a-menu-item key="logout" @click="handleLogout">
                  <LogoutOutlined /> 退出登录
                </a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
        </div>
      </a-layout-header>
      <a-layout-content
        :style="{
          margin: isMobile ? '0' : '24px 16px',
          padding: isMobile ? '16px' : '24px',
          background: isMobile ? '#f0f2f5' : '#f0f2f5',
          minHeight: '280px',
          overflowY: 'auto',
          flex: 1,
        }"
      >
        <router-view></router-view>
      </a-layout-content>
    </a-layout>

    <!-- Notification Detail Modal -->
    <a-modal
      v-model:open="notificationDetailVisible"
      :title="selectedNotification?.title || '消息详情'"
      :footer="null"
      @cancel="notificationDetailVisible = false"
    >
      <div class="py-4">
        <div class="text-xs text-gray-400 mb-4">
          {{
            selectedNotification?.createdAt
              ? new Date(selectedNotification.createdAt).toLocaleString()
              : ""
          }}
        </div>
        <div class="text-gray-700 whitespace-pre-wrap leading-relaxed">
          {{ selectedNotification?.content }}
        </div>
      </div>
    </a-modal>
    <!-- Publish Announcement Modal -->
    <a-modal
      v-model:open="announcementVisible"
      title="发布系统全局公告"
      :confirmLoading="publishingAnnouncement"
      @ok="handlePublishAnnouncement"
      @cancel="announcementVisible = false"
    >
      <div class="py-4">
        <div class="mb-4">
          <div class="mb-2 text-gray-700">公告标题：</div>
          <a-input v-model:value="announcementTitle" placeholder="请输入公告标题（例如：关于春季认养活动的通知）" />
        </div>
        <div>
          <div class="mb-2 text-gray-700">公告内容：</div>
          <a-textarea
            v-model:value="announcementContent"
            placeholder="请输入公告正文..."
            :rows="6"
          />
        </div>
      </div>
    </a-modal>

  </a-layout>
</template>

<script lang="ts" setup>
import { ref, computed, h, onMounted, onUnmounted, watch, nextTick } from "vue"; // Added nextTick
import { useRouter, useRoute } from "vue-router";
import {
  UserOutlined,
  MenuUnfoldOutlined,
  MenuFoldOutlined,
  LogoutOutlined,
  BellOutlined,
  DeleteOutlined,
  CheckOutlined,
} from "@ant-design/icons-vue";
import { getMenusByRole } from "@/config/menu";
import {
  Badge,
  Modal,
  List,
  Avatar,
  Popover,
  Empty,
  Button,
  Tooltip,
  message,
} from "ant-design-vue";
import { getPendingAuditCount } from "@/api/adoption";
import {
  getNotificationList,
  getUnreadCount,
  markAllAsRead,
  markAsRead,
  publishAnnouncement,
  type SystemNotification,
} from "@/api/notification";

// ... existing code ...

const collapsed = ref(false);
const drawerVisible = ref(false);
const isMobile = ref(false);

const router = useRouter();
const route = useRoute();
const selectedKeys = ref<string[]>([]); // Initialize empty
const openKeys = ref<string[]>([]);
const username = ref(localStorage.getItem("realName") || "用户"); // Make reactive
const role = ref(localStorage.getItem("role") || "USER"); // Make reactive
const avatarUrl = ref(localStorage.getItem("avatarUrl") || "");
const pendingAuditCount = ref(0);

// Notification State
const unreadNotificationCount = ref(0);
const notifications = ref<SystemNotification[]>([]);
const notificationVisible = ref(false);
const notificationLoading = ref(false);

const notificationDetailVisible = ref(false);
const selectedNotification = ref<SystemNotification | null>(null);

// Announcement state
const announcementVisible = ref(false);
const publishingAnnouncement = ref(false);
const announcementTitle = ref("");
const announcementContent = ref("");

const handleViewNotification = async (item: SystemNotification) => {
  selectedNotification.value = item;
  notificationDetailVisible.value = true;

  if (item.isRead === 0) {
    try {
      await markAsRead(item.id);
      // Update local state to immediately show as read
      item.isRead = 1;
      unreadNotificationCount.value = Math.max(
        0,
        unreadNotificationCount.value - 1,
      );
    } catch (e) {
      console.error("Failed to mark notification as read", e);
    }
  }
};

const syncUserFromStorage = () => {
  username.value = localStorage.getItem("realName") || "用户";
  role.value = localStorage.getItem("role") || "USER";
  avatarUrl.value = localStorage.getItem("avatarUrl") || "";
};

// Watch route changes to update selected menu
watch(
  () => route.path,
  (newPath) => {
    selectedKeys.value = [newPath];
    // Optional: Logic to open submenu if needed, but 'openKeys' is usually controlled by user or initial state
  },
);

// Check screen size
const checkMobile = () => {
  const wasMobile = isMobile.value;
  isMobile.value = window.innerWidth <= 768;
  if (!wasMobile && isMobile.value) {
    collapsed.value = false; // Reset collapsed state when switching to mobile
  }
};

const toggleMenu = () => {
  if (isMobile.value) {
    drawerVisible.value = !drawerVisible.value;
  } else {
    collapsed.value = !collapsed.value;
  }
};

// Generate menu items structure for Ant Design Vue Menu
const menuItems = computed(() => {
  const menus = getMenusByRole(role.value); // Use reactive role
  return menus.map((item) => {
    if (item.type === "group") {
      return {
        key: item.key,
        label: item.label,
        type: "group",
        children: item.children?.map((child) => {
          let labelVNode: any = child.label;
          // Add badge for Audit Applications
          if (
            child.key === "/user/audit-applications" &&
            pendingAuditCount.value > 0
          ) {
            labelVNode = h(
              "div",
              { class: "flex items-center justify-between w-full pr-4" },
              [
                h("span", child.label),
                h(Badge, {
                  count: pendingAuditCount.value,
                  numberStyle: { backgroundColor: "#ff4d4f" },
                }),
              ],
            );
          }
          return {
            key: child.key,
            label: labelVNode,
            // Directly pass the icon component if available, fallback to function if complex
            icon: child.icon ? h(child.icon) : undefined,
          };
        }),
      };
    }
    return {
      key: item.key,
      label: item.label,
      icon: item.icon ? h(item.icon) : undefined,
      children: item.children,
    };
  });
});

const fetchPendingCount = async () => {
  // If we don't have a token, don't fetch pending count
  if (!localStorage.getItem("token")) {
    return;
  }

  if (role.value === "ADMIN") {
    // Use reactive role
    try {
      const res: any = await getPendingAuditCount();
      pendingAuditCount.value = res;
    } catch (e) {
      console.error("Failed to fetch pending audit count", e);
    }
  }
};

const fetchNotifications = async () => {
  // If we don't have a token, don't fetch notifications
  if (!localStorage.getItem("token")) {
    return;
  }

  notificationLoading.value = true;
  try {
    const res: any = await getNotificationList(10); // Top 10
    notifications.value = res;
    const countRes: any = await getUnreadCount();
    unreadNotificationCount.value = Number(countRes);
  } catch (e) {
    console.error("Failed to fetch notifications", e);
  } finally {
    notificationLoading.value = false;
  }
};

const handleMarkAllRead = async () => {
  try {
    await markAllAsRead();
    message.success("全部已读");
    fetchNotifications();
  } catch (e) {
    message.error("操作失败");
  }
};

const handleNotificationClick = () => {
  // Just toggle visible handled by popover, but maybe refresh
  if (!notificationVisible.value) {
    fetchNotifications();
  }
};

const handleMenuClick = ({ key }: { key: string }) => {
  router.push(key);
  if (isMobile.value) {
    drawerVisible.value = false; // Close drawer on navigation
  }
};

const handleLogout = () => {
  Modal.confirm({
    title: "确认退出",
    content: "确定要退出登录吗？",
    okText: "确认",
    cancelText: "取消",
    onOk() {
      localStorage.clear();
      router.push("/login");
    },
  });
};

const handlePublishAnnouncement = async () => {
  if (!announcementTitle.value.trim() || !announcementContent.value.trim()) {
    message.warning("公告标题和内容不能为空");
    return;
  }
  
  publishingAnnouncement.value = true;
  try {
    await publishAnnouncement(announcementTitle.value, announcementContent.value);
    message.success("全局公告发布成功，已推送至所有用户");
    announcementVisible.value = false;
    announcementTitle.value = "";
    announcementContent.value = "";
    // Refresh admin's own list too
    fetchNotifications();
  } catch (error: any) {
    message.error(error.message || "发布公告失败");
  } finally {
    publishingAnnouncement.value = false;
  }
};

// Polling for updates
let timer: any = null;

onMounted(async () => {
  // Async mounted
  // Ensure we get latest from localStorage in case of page refresh or redirect
  syncUserFromStorage();

  // Set initial selected keys
  await nextTick();
  selectedKeys.value = [route.path];

  checkMobile();
  window.addEventListener("resize", checkMobile);
  fetchPendingCount();
  fetchNotifications(); // Initial fetch

  // Refresh count every 30 seconds
  timer = setInterval(() => {
    fetchPendingCount();
    fetchNotifications();
  }, 30000);

  window.addEventListener("user-profile-updated", syncUserFromStorage);
});
// ...

onUnmounted(() => {
  window.removeEventListener("resize", checkMobile);
  window.removeEventListener("user-profile-updated", syncUserFromStorage);
  if (timer) clearInterval(timer);
});
</script>

<style scoped>
.trigger {
  font-size: 18px;
  line-height: 64px;
  padding: 0 24px;
  cursor: pointer;
  transition: color 0.3s;
}
.trigger:hover {
  color: #1890ff;
}
</style>
