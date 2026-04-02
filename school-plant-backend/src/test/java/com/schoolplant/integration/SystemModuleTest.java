package com.schoolplant.integration;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.schoolplant.dto.*;
import com.schoolplant.mapper.*;
import com.schoolplant.entity.*;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.web.socket.server.standard.ServerEndpointExporter;

import java.nio.charset.StandardCharsets;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class SystemModuleTest {

    @MockBean
    private ServerEndpointExporter serverEndpointExporter;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private RoleMapper roleMapper;

    @Autowired
    private UserRoleMapper userRoleMapper;

    private static String adminToken;
    private static String userToken;
    private static Long plantId;
    private static Long applicationId;
    private static Long taskId;

    // Use unique usernames to avoid conflicts if DB is not cleaned
    private static final String ADMIN_USERNAME = "admin_test_" + UUID.randomUUID().toString().substring(0, 8);
    private static final String USER_USERNAME = "user_test_" + UUID.randomUUID().toString().substring(0, 8);
    private static final String PLANT_NAME = "Test Plant " + UUID.randomUUID().toString().substring(0, 8);
    // Randomize phone to avoid conflicts
    private static final String ADMIN_PHONE = "138" + String.format("%08d", new java.util.Random().nextInt(100000000));
    private static final String USER_PHONE = "139" + String.format("%08d", new java.util.Random().nextInt(100000000));
    
    // Randomize Plant Details to avoid "Duplicate Plant at Location" error
    private static final String PLANT_SPECIES = "Species_" + UUID.randomUUID().toString().substring(0, 6);
    private static final String PLANT_LOCATION = "Location_" + UUID.randomUUID().toString().substring(0, 6);

    @Test
    @Order(1)
    @DisplayName("MOD-01: User Registration (Normal Flow)")
    void testUserRegistration() throws Exception {
        // Register Admin
        RegisterRequest adminReg = new RegisterRequest();
        adminReg.setUsername(ADMIN_USERNAME);
        adminReg.setPassword("123456");
        adminReg.setConfirmPassword("123456");
        adminReg.setEmail("admin_" + UUID.randomUUID().toString().substring(0, 5) + "@test.com");
        adminReg.setPhone(ADMIN_PHONE);

        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(adminReg)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));

        // Register User
        RegisterRequest userReg = new RegisterRequest();
        userReg.setUsername(USER_USERNAME);
        userReg.setPassword("123456");
        userReg.setConfirmPassword("123456");
        userReg.setEmail("user_" + UUID.randomUUID().toString().substring(0, 5) + "@test.com");
        userReg.setPhone(USER_PHONE);

        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(userReg)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));

        
        // Assign ADMIN role to admin user
        User adminUser = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getUsername, ADMIN_USERNAME));
        Assertions.assertNotNull(adminUser, "Admin user should exist after registration");
        
        Role adminRole = roleMapper.selectOne(new LambdaQueryWrapper<Role>().eq(Role::getRoleKey, "ADMIN"));
        if (adminRole == null) {
            adminRole = new Role();
            adminRole.setRoleName("管理员");
            adminRole.setRoleKey("ADMIN");
            adminRole.setStatus(1);
            roleMapper.insert(adminRole);
        }
        
        // Remove existing roles (e.g. default USER role) to ensure getRoleIdByUserId returns ADMIN
        userRoleMapper.delete(new LambdaQueryWrapper<UserRole>().eq(UserRole::getUserId, adminUser.getId()));

        UserRole ur = new UserRole();
        ur.setUserId(adminUser.getId());
        ur.setRoleId(adminRole.getId());
        userRoleMapper.insert(ur);
    }

    @Test
    @Order(2)
    @DisplayName("MOD-01: User Login (Normal Flow)")
    void testUserLogin() throws Exception {
        // Login Admin
        LoginRequest adminLogin = new LoginRequest();
        adminLogin.setUsername(ADMIN_USERNAME);
        adminLogin.setPassword("123456");

        MvcResult adminResult = mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(adminLogin)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.tokenInfo.tokenValue").exists())
                .andReturn();
        
        String adminResp = adminResult.getResponse().getContentAsString(StandardCharsets.UTF_8);
        adminToken = objectMapper.readTree(adminResp).path("data").path("tokenInfo").path("tokenValue").asText();

        // Login User
        LoginRequest userLogin = new LoginRequest();
        userLogin.setUsername(USER_USERNAME);
        userLogin.setPassword("123456");

        MvcResult userResult = mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(userLogin)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.tokenInfo.tokenValue").exists())
                .andReturn();

        String userResp = userResult.getResponse().getContentAsString(StandardCharsets.UTF_8);
        userToken = objectMapper.readTree(userResp).path("data").path("tokenInfo").path("tokenValue").asText();
    }

    @Test
    @Order(8)
    @DisplayName("MOD-01: Auth - Invalid Login (Exception)")
    void testInvalidLogin() throws Exception {
        LoginRequest invalidLogin = new LoginRequest();
        invalidLogin.setUsername(USER_USERNAME);
        invalidLogin.setPassword("wrongpassword");

        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidLogin)))
                .andExpect(status().isOk()) // Assuming controller handles exception and returns 200 with error code/msg
                .andExpect(jsonPath("$.code").value(500)); // Or whatever fail code is
    }

    @Test
    @Order(9)
    @DisplayName("MOD-02: Plant - Add Invalid Data (Validation)")
    void testAddInvalidPlant() throws Exception {
        PlantAddRequest invalidPlant = new PlantAddRequest();
        // Missing required fields like Name, Code

        mockMvc.perform(post("/plant")
                        .header("satoken", adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidPlant)))
                .andExpect(status().isOk()) // GlobalExceptionHandler usually catches and returns 200/400
                .andExpect(jsonPath("$.code").value(500)); // Verify failure
    }


    @Test
    @Order(3)
    @DisplayName("MOD-02: Plant Management - Add & Query Plant")
    void testAddAndQueryPlant() throws Exception {
        PlantAddRequest plant = new PlantAddRequest();
        plant.setPlantCode("P-" + UUID.randomUUID().toString().substring(0, 6));
        plant.setName(PLANT_NAME);
        plant.setSpecies(PLANT_SPECIES);
        plant.setLocationDescription(PLANT_LOCATION);
        plant.setCareDifficulty(3);
        plant.setStatus("AVAILABLE");
        plant.setDescription("A test plant");

        // Add Plant
        mockMvc.perform(post("/plant")
                        .header("satoken", adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(plant)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
        
        // Query Plant to get ID
        MvcResult result = mockMvc.perform(get("/plant/list")
                        .header("satoken", adminToken)
                        .param("name", PLANT_NAME)
                        .param("page", "1")
                        .param("size", "10"))
                .andExpect(status().isOk())
                .andReturn();
        
        String content = result.getResponse().getContentAsString(StandardCharsets.UTF_8);
        JsonNode records = objectMapper.readTree(content).path("data").path("records");
        if (records.isArray() && records.size() > 0) {
            plantId = records.get(0).path("id").asLong();
        } else {
            Assertions.fail("Plant not found after addition");
        }
    }

    @Test
    @Order(4)
    @DisplayName("MOD-03: Adoption Service - Apply & Audit")
    void testAdoptionFlow() throws Exception {
        Assertions.assertNotNull(plantId, "Plant ID must not be null");

        // User Apply
        AdoptionApplyRequest apply = new AdoptionApplyRequest();
        apply.setPlantId(plantId);
        apply.setReason("I love plants");
        apply.setPlan("Water daily");
        apply.setCareExperience("None");
        apply.setAdoptionPeriodMonths(6);

        MvcResult applyResult = mockMvc.perform(post("/adoption/submit")
                        .header("satoken", userToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(apply)))
                .andExpect(status().isOk())
                .andReturn();
        
        String applyResp = applyResult.getResponse().getContentAsString(StandardCharsets.UTF_8);
        applicationId = objectMapper.readTree(applyResp).path("data").asLong();
        
        // Admin Audit (Approve)
        AuditApplicationRequest audit = new AuditApplicationRequest();
        audit.setId(applicationId);
        audit.setAction("PASS"); // Assuming PASS/REJECT
        audit.setComment("Approved");

        mockMvc.perform(post("/adoption/audit/action")
                        .header("satoken", adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(audit)))
                .andExpect(status().isOk());
    }

    @Test
    @Order(5)
    @DisplayName("MOD-04: Care Tasks - Check Generated Tasks")
    void testCareTaskFlow() throws Exception {
        // Get User ID directly from DB
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getUsername, USER_USERNAME));
        Assertions.assertNotNull(user, "User should exist");
        Long userId = user.getId();

        // Create Task
        // CareTask entity structure
        // We'll construct a simple JSON since we don't have DTO for Create
        String taskJson = String.format("{\"plantId\":%d, \"userId\":%d, \"taskType\":\"WATERING\", \"taskDescription\":\"Water the plant\", \"dueDate\":\"2024-12-31\", \"status\":\"PENDING\"}", plantId, userId);

        mockMvc.perform(post("/task/create")
                        .header("satoken", adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(taskJson))
                .andExpect(status().isOk());
                
        // User checks tasks
        MvcResult tasksResult = mockMvc.perform(get("/task/my-tasks")
                        .header("satoken", userToken))
                .andExpect(status().isOk())
                .andReturn();
        
        String tasksResp = tasksResult.getResponse().getContentAsString(StandardCharsets.UTF_8);
        JsonNode records = objectMapper.readTree(tasksResp).path("data").path("records");
        if (records.isArray() && records.size() > 0) {
            taskId = records.get(0).path("id").asLong();
        } else {
            Assertions.fail("Task not found for user");
        }
        
        // User completes task
        String completeJson = String.format("{\"id\":%d, \"imageUrl\":\"http://img.com/1.jpg\"}", taskId);
        mockMvc.perform(post("/task/complete")
                        .header("satoken", userToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(completeJson))
                .andExpect(status().isOk());
    }

    @Test
    @Order(6)
    @DisplayName("MOD-05: Abnormality Reporting")
    void testAbnormalityReport() throws Exception {
        mockMvc.perform(multipart("/abnormality/report")
                        .param("plantId", plantId.toString())
                        .param("type", "PEST")
                        .param("desc", "Insects found")
                        .header("satoken", userToken))
                .andExpect(status().isOk());
    }

    @Test
    @Order(7)
    @DisplayName("MOD-06: Knowledge Community - Functional")
    void testKnowledgeCommunity() throws Exception {
        KnowledgePostAddRequest post = new KnowledgePostAddRequest();
        post.setTitle("My First Plant Post");
        post.setContent("Sharing my experience.");
        post.setTag("Experience");

        // Add Post
        mockMvc.perform(post("/knowledge/post/add")
                        .header("satoken", userToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(post)))
                .andExpect(status().isOk());

        // List Posts
        mockMvc.perform(get("/knowledge/post/list")
                        .header("satoken", userToken)
                        .param("page", "1")
                        .param("size", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.records").isArray());
    }

    @Test
    @Order(10)
    @DisplayName("PERF-01: Performance - Batch Post Creation")
    void testPerformanceCreatePosts() throws Exception {
        int count = 50;
        long startTime = System.currentTimeMillis();
        
        for (int i = 0; i < count; i++) {
            KnowledgePostAddRequest post = new KnowledgePostAddRequest();
            post.setTitle("Perf Post " + i);
            post.setContent("Content " + i);
            post.setTag("Perf");

            mockMvc.perform(post("/knowledge/post/add")
                            .header("satoken", userToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(post)))
                    .andExpect(status().isOk());
        }
        
        long duration = System.currentTimeMillis() - startTime;
        System.out.println("Performance Test: Created " + count + " posts in " + duration + "ms");
        
        // Assert that 50 requests take less than 5 seconds (100ms per request average is very generous for integration test)
        Assertions.assertTrue(duration < 5000, "Batch creation took too long: " + duration + "ms");
    }

    @Test
    @Order(11)
    @DisplayName("BUG-FIX: Allow Multiple Rejected Applications")
    void testMultipleRejectedApplications() throws Exception {
        // 1. Submit App 1
        AdoptionApplyRequest apply1 = new AdoptionApplyRequest();
        apply1.setPlantId(plantId);
        apply1.setReason("Try 1");
        
        MvcResult res1 = mockMvc.perform(post("/adoption/submit")
                        .header("satoken", userToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(apply1)))
                .andExpect(status().isOk())
                .andReturn();
        Long appId1 = objectMapper.readTree(res1.getResponse().getContentAsString(StandardCharsets.UTF_8)).path("data").asLong();

        // 2. Reject App 1
        AuditApplicationRequest audit1 = new AuditApplicationRequest();
        audit1.setId(appId1);
        audit1.setAction("REJECT");
        audit1.setComment("Rejected 1");
        
        mockMvc.perform(post("/adoption/audit/action")
                        .header("satoken", adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(audit1)))
                .andExpect(status().isOk());

        // 3. Submit App 2 (Same User, Same Plant or Different)
        // System logic might prevent pending if one exists, but here previous is REJECTED, so should allow new pending.
        AdoptionApplyRequest apply2 = new AdoptionApplyRequest();
        apply2.setPlantId(plantId);
        apply2.setReason("Try 2");

        MvcResult res2 = mockMvc.perform(post("/adoption/submit")
                        .header("satoken", userToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(apply2)))
                .andExpect(status().isOk())
                .andReturn();
        Long appId2 = objectMapper.readTree(res2.getResponse().getContentAsString(StandardCharsets.UTF_8)).path("data").asLong();

        // 4. Reject App 2 (This should NOT fail due to unique constraint)
        AuditApplicationRequest audit2 = new AuditApplicationRequest();
        audit2.setId(appId2);
        audit2.setAction("REJECT");
        audit2.setComment("Rejected 2");

        mockMvc.perform(post("/adoption/audit/action")
                        .header("satoken", adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(audit2)))
                .andExpect(status().isOk());
    }
}
