 kafka 基础知识

![kafka](http://matt33.com/images/2015-11-14-kafka-introduce/kafka.png)

- **Topic**：特指Kafka处理的消息源的不同分类，其实也可以理解为对不同消息源的区分的一个标识；
- **Partition**：Topic物理上的分组，一个topic可以设置为多个partition，每个partition都是一个有序的队列，partition中的每条消息都会被分配一个有序的id（offset）；
- **Message**：消息，是通信的基本单位，每个producer可以向一个topic（主题）发送一些消息；
- **Producers**：消息和数据生产者，向Kafka的一个topic发送消息的过程叫做producers（producer可以选择向topic哪一个partition发送数据）。
- **Consumers**：消息和数据消费者，接收topics并处理其发布的消息的过程叫做consumer，同一个topic的数据可以被多个consumer接收；
- **Broker**：缓存代理，Kafka集群中的一台或多台服务器统称为broker。

![log](http://matt33.com/images/2015-11-14-kafka-introduce/log.png)

在调用conusmer API时，一般都会指定一个consumer group，该group订阅的topic的每一条消息都发送到这个group的某一台机器上。借用官网一张图来详细介绍一下这种情况，假如kafka集群有两台broker，集群上有一个topic，它有4个partition，partition 0和1在broker1上，partition 2和3在broker2上，这时有两个consumer group同时订阅这个topic，其中一个group有2个consumer，另一个consumer有4个consumer，则它们的订阅消息情况如下图所示：

[![consumerGroup](http://matt33.com/images/2015-11-14-kafka-introduce/consumerGroup.png)](http://matt33.com/images/2015-11-14-kafka-introduce/consumerGroup.png)consumerGroup

因为group A只有两个consumer，所以一个consumer会消费两个partition；而group B有4个consumer，一个consumer会去消费一个partition。这里要注意的是，kafka可以保证一个**partition内的数据是有序的**，所以group B中的consumer收到的数据是可以保证有序的，但是Group A中的consumer就无法保证了。

group读取topic，**partition分配**机制是：

- 如果group中的consumer数小于topic中的partition数，那么group中的consumer就会消费多个partition；
- 如果group中的consumer数等于topic中的partition数，那么group中的一个consumer就会消费topic中的一个partition；
- 如果group中的consumer数大于topic中的partition数，那么group中就会有一部分的consumer处于空闲状态。