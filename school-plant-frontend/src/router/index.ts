import {
  createRouter,
  createWebHistory,
  type RouteRecordRaw,
} from "vue-router";
import UserCenterLayout from "@/layout/UserCenterLayout.vue";
import Login from "@/views/Login.vue";

// 定义路由配置
const routes: Array<RouteRecordRaw> = [
  {
    path: "/login",
    name: "Login",
    component: Login,
  },
  {
    path: "/",
    component: UserCenterLayout,
    redirect: "/user/overview",
    children: [
      {
        path: "user/overview",
        name: "Dashboard",
        component: () => import("@/views/UserCenter/Overview.vue"),
      },
      {
        path: "user/profile",
        name: "UserProfile",
        component: () => import("@/views/UserCenter/Profile.vue"),
      },
      // USER
      {
        path: "user/plant-search",
        name: "PlantSearch",
        component: () => import("@/views/PlantSearch/index.vue"),
      },
      {
        path: "user/my-applications",
        name: "MyApplications",
        component: () => import("@/views/Adoption/MyApplications.vue"),
      },
      {
        path: "user/my-adoptions",
        name: "MyAdoptions",
        component: () => import("@/views/Adoption/MyAdoptions.vue"),
      },
      {
        path: "user/initial-audit",
        name: "InitialAudit",
        component: () => import("@/views/Adoption/InitialAudit.vue"),
      },
      {
        path: "user/my-tasks",
        name: "MyTasks",
        component: () => import("@/views/TaskManage/MyTasks.vue"),
      },
      {
        path: "user/my-abnormalities",
        name: "MyAbnormalities",
        component: () => import("@/views/Abnormality/MyReports.vue"),
      },
      {
        path: "user/abnormality-report",
        name: "AbnormalityReport",
        component: () => import("@/views/Abnormality/Report.vue"),
      },
      {
        path: "user/my-achievements",
        name: "MyAchievements",
        component: () => import("@/views/Achievement/MyAchievements.vue"),
      },
      {
        path: "user/knowledge-share",
        name: "KnowledgeShare",
        component: () => import("@/views/KnowledgeShare/index.vue"),
      },
      // ADMIN
      {
        path: "user/plant-manage",
        name: "PlantManage",
        component: () => import("@/views/PlantManage/index.vue"),
      },
      {
        path: "user/audit-applications",
        name: "AuditApplications",
        component: () => import("@/views/Adoption/Audit.vue"),
      },
      {
        path: "user/task-manage",
        name: "TaskManage",
        component: () => import("@/views/TaskManage/index.vue"),
      },
      {
        path: "user/abnormality-manage",
        name: "AbnormalityManage",
        component: () => import("@/views/Abnormality/Manage.vue"),
      },
      {
        path: "user/achievement-eval",
        name: "AchievementEval",
        component: () => import("@/views/Achievement/Eval.vue"),
      },
      {
        path: "user/content-audit",
        name: "ContentAudit",
        component: () => import("@/views/KnowledgeShare/Audit.vue"),
      },
      {
        path: "user/content-reports",
        name: "ContentReports",
        component: () => import("@/views/KnowledgeShare/ReportManage.vue"),
      },
      {
        path: "user/user-manage",
        name: "UserManage",
        component: () => import("@/views/UserManage/index.vue"),
      },
      {
        path: "user/system-params",
        name: "SystemParams",
        component: () => import("@/views/System/Parameter.vue"),
      },
      {
        path: "user/operation-logs",
        name: "OperationLogs",
        component: () => import("@/views/System/Log.vue"),
      },
      // MAINTAINER
      {
        path: "user/maintainer-tracking",
        name: "MaintainerTracking",
        component: () => import("@/views/TaskManage/index.vue"), // Or a specific tracking view if exists
      },
      {
        path: "user/maintainer-records",
        name: "MaintainerRecords",
        component: () => import("@/views/System/Log.vue"), // Placeholder or specific view
      },
    ],
  },
  // Fallback
  {
    path: "/:pathMatch(.*)*",
    redirect: "/login",
  },
];

// 创建路由实例
const router = createRouter({
  history: createWebHistory(),
  routes,
});

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem("token");

  // 已登录用户访问登录页，重定向到个人中心
  if (to.path === "/login" && token) {
    next("/user/overview");
    return;
  }

  // 未登录用户访问非登录页，重定向到登录页
  if (to.path !== "/login" && !token) {
    next("/login");
  } else {
    next();
  }
});

export default router;
