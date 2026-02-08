/**
 * 环境变量类型定义
 */

declare global {
	interface Env {
		/**
		 * 后端 API 地址（必填）
		 *
		 * 注意：/api/email/receive 接口无需认证
		 */
		API_URL: string;

		/**
		 * 测试服务器 API 地址（可选）
		 * 配置后会同时转发到测试服务器
		 */
		TEST_API_URL?: string;
	}
}

export {};
