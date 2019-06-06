# Concept

## OS Elements

* Abstractions 
  * process
  *  thread
  * file
  * socket
  * memory
  * page
* Mechanisms
  * create	
  * schedule
  * open
  * write
  * allocate(分配)
* Policies(策略)
  * least-recently used(LRU)
  * earliest deadline first (EDF)



关于Mechanisms 和 Polices的区别我其实迷惑了很久。

其实总结出来很简单Mechanisms 机制 指的是 what to do

Polices 指的是 how to do

也可以这样理解机制是策略的更高一层抽象，策略是指具体如何实现的方式，机制则是我需要这个功能，但是不关注实现。

举个例子就是Linux内核的调度器（scheduler），提供了任务调度需要的原语操作和结构，并且实现了多种调度算法。

## Process 

* instance of an executing program
* Synonymous with "task" or "job"



A process is like an order of toys

* State of execution

  * program counter
  * stack

* parts & temporary holding area

  * data. register state, occupies state in memory

* may require special hardware

  * I/O devices

  