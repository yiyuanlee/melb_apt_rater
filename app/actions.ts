'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';
import { headers } from 'next/headers';

export async function submitReview(formData: FormData) {
  const apartmentId = formData.get('apartmentId') as string;
  // 确保分数是数字
  const score = parseInt(formData.get('score') as string);
  const content = formData.get('content') as string;

  // 1. 获取用户 IP (Next.js 15+ headers 是异步的)
  const headersList = await headers();
  const ip = headersList.get('x-forwarded-for') || 'unknown';
  
  // 生成简单的 IP 指纹 (防止刷分)
  const ipHash = btoa(ip).slice(0, 10); 

  // 2. 检查该 IP 是否在 24 小时内给该公寓打过分
  const { data: existing } = await supabase
    .from('reviews')
    .select('id')
    .eq('apartment_id', apartmentId)
    .eq('ip_hash', ipHash)
    .gte('created_at', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString())
    .single();

  if (existing) {
    return { error: '⚠️ 提交太频繁了，24小时内只能评一次哦' };
  }

  // 3. 写入数据库
  const { error } = await supabase.from('reviews').insert({
    apartment_id: apartmentId,
    score: score,
    content: content,
    ip_hash: ipHash,
  });

  if (error) {
    console.error('Supabase Error:', error);
    return { error: '提交失败，请重试' };
  }

  // 4. 🚀 关键步骤：清除缓存，强制刷新数据
  
  // 刷新详情页：让用户立刻看到自己的评论
  revalidatePath(`/apartment/${apartmentId}`);

  // 🛑 刷新首页：让首页的"平均分"和"评分人数"也立刻变动
  revalidatePath('/');

  return { success: true };
}