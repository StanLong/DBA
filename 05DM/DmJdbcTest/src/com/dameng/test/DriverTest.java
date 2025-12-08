package com.dameng.test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class DriverTest {
    public static void main(String[] args) {
        // ########## 需根据实际环境修改以下3处 ##########
        final String URL = "jdbc:dm://DM8_DKY/"; // 主机IP:端口（默认5236）
        final String USER = "SYSDBA"; // 步骤3创建的用户名
        final String PWD = "yunJs@12"; // 步骤3设置的密码
        // #############################################

        // 达梦驱动类名（DM8/DM9通用，无需修改）
        final String DRIVER = "dm.jdbc.driver.DmDriver";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            // 1. 加载驱动（验证驱动是否能找到）
            Class.forName(DRIVER);
            System.out.println("✅ 达梦驱动加载成功！");

            // 2. 连接数据库（验证连接是否正常）
            conn = DriverManager.getConnection(URL, USER, PWD);
            System.out.println("✅ 数据库连接成功！");

            // 3. 执行查询（验证驱动功能正常）
            stmt = conn.createStatement();
            String sql = "SELECT ID, NAME, CREATE_TIME FROM TEST_TABLE";
            rs = stmt.executeQuery(sql);

            // 4. 打印结果
            System.out.println("\n📊 查询测试数据：");
            while (rs.next()) {
                int id = rs.getInt("ID");
                String name = rs.getString("NAME");
                String time = rs.getString("CREATE_TIME");
                System.out.printf("ID: %d, 名称: %s, 创建时间: %s\n", id, name, time);
            }

        } catch (ClassNotFoundException e) {
            System.err.println("❌ 驱动加载失败！原因：" + e.getMessage());
            System.err.println("排查：1. 驱动包是否导入 2. 驱动类名是否正确");
        } catch (Exception e) {
            System.err.println("❌ 连接/查询失败！原因：" + e.getMessage());
            System.err.println("排查：1. 数据库服务是否启动 2. URL/账号/密码是否正确 3. 防火墙是否开放5236端口");
        } finally {
            // 5. 关闭资源（避免泄露）
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
                System.out.println("\n🔌 资源关闭成功！");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}