/**
 * Cloudflare Email Worker - 邮件转发服务
 */

import MimeParser from 'postal-mime';
import { sendEmailToAPI } from './api-client';

export default {
	async email(message: ForwardableEmailMessage, env: Env, _ctx: ExecutionContext) {
		console.log(`📧 收到邮件: ${message.from} -> ${message.to}`);

		try {
			// 解析邮件
			const email = await parseEmail(message);
			console.log(`✅ 解析成功 - ${email.subject || '(无主题)'}`);

			// 不在 Worker 端过滤，所有邮件都转发到服务端统一处理

			// 准备邮件数据（匹配后端接口格式）
			const emailData = {
				to: message.to, // 必填
				from: email.from || null, // 可选
				subject: email.subject || null, // 可选
				text: email.text || null, // 可选
				html: email.html || null, // 可选
			};

			// 转发完整邮件（生产环境）
			const prodSuccess = await sendEmailToAPI(emailData, env.API_URL);
			console.log(prodSuccess ? '✅ 生产环境转发成功' : '⚠️ 生产环境转发失败');

			// 同时转发到测试服务器（如果配置了）
			if (env.TEST_API_URL) {
				const testSuccess = await sendEmailToAPI(emailData, env.TEST_API_URL);
				console.log(testSuccess ? '✅ 测试服务器转发成功' : '⚠️ 测试服务器转发失败');
			}
		} catch (error) {
			console.error('❌ 邮件处理失败:', error);
		}
	},
};

/**
 * 解析邮件内容
 */
async function parseEmail(message: ForwardableEmailMessage) {
	const arrayBuffer = await new Response(message.raw).arrayBuffer();
	const parser = new MimeParser();
	const email = await parser.parse(arrayBuffer);

	// 提取文本内容
	const text = email.text || (email.html ? email.html.replace(/<[^>]*>/g, ' ') : '');
	const html = email.html || '';

	return {
		text: text || '',
		html: html || '',
		subject: email.subject || '',
		from: email.from?.address || message.from || '',
	};
}
