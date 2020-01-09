方案:

1.对于查询 QueryActor 的失败查询，传入封装好的 GroupUsersRequest 内部包含对应的请求偏移量给 重试的Actor

2.通过模式匹配获得数组的第一个睡眠的时间长度，随后先执行睡眠操作，因为上一次的重试或者QueryActor 刚刚结束。

3.随后执行对应的请求操作，判断是否成功。

4.如果重试成功，记录当前重试的次数，与重试的总计用时，以及GroupUsersRequest 中的ai，查询的url ，写入retry_qs_invoke 表中,随后对成功的数据执行 QueryActor 相同的逻辑，对数据根据channel 分类随后建立 JobContext 交付给 checkpointTaskActor 处理，逻辑和 QueryActor 查询成功的逻辑类似。
5.A:如果重试失败，并且剩下的重试 List 为空，就记录重试的总计用时，以及GroupUsersRequest 中的 ai，查询的url ，写入 retry_qs_invoke 表中。B:如果重试失败，并且剩下的List不为空，就将剩下的List 与 GroupUsersRequest
传入 RetryActor 调用自己。

