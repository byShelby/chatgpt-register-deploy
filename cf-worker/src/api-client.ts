/**
 * API 调用模块
 */

interface EmailData {
	to: string;
	from: string | null;
	subject: string | null;
	text: string | null;
	html: string | null;
}

/**
 * 发送完整邮件数据到 API
 *
 * 注意：/api/email/receive 接口不需要认证
 */
export async function sendEmailToAPI(emailData: EmailData, apiUrl?: string): Promise<boolean> {
	if (!apiUrl) {
		console.warn('⚠️ 未配置 API_URL');
		return false;
	}

	try {
		const response = await fetch(apiUrl, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify(emailData),
		});

		if (!response.ok) {
			const responseText = await response.text();
			console.error(`API 错误: ${response.status}`, responseText);
			return false;
		}

		return true;
	} catch (error) {
		console.error('API 调用失败:', error);
		return false;
	}
}
