## [process state for linux define](https://github.com/torvalds/linux/blob/b6da0076bab5a12afb19312ffee41c95490af2a0/fs/proc/array.c#L129)

```
/*
 * The task state array is a strange "bitmap" of
 * reasons to sleep. Thus "running" is zero, and
 * you can test for combinations of others with
 * simple bit tests.
 */
static const char * const task_state_array[] = {
	"R (running)",		/*   0 */
	"S (sleeping)",		/*   1 */
	"D (disk sleep)",	/*   2 */
	"T (stopped)",		/*   4 */
	"t (tracing stop)",	/*   8 */
	"X (dead)",		/*  16 */
	"Z (zombie)",		/*  32 */
};
```

## process (concurrent-programming-and-parallel-programming)

`parallel concurrent`

> [what-is-the-difference-between-concurrency-and-parallelism](https://stackoverflow.com/questions/1050222/what-is-the-difference-between-concurrency-and-parallelism)

>[What is the difference between concurrent programming and parallel programming?](https://stackoverflow.com/questions/1897993/what-is-the-difference-between-concurrent-programming-and-parallel-programming)

### process

[]

sleep[glic] -> nanosleep[kernel]

> [whats-the-algorithm-behind-sleep](https://stackoverflow.com/questions/175882/whats-the-algorithm-behind-sleep)

	* Multi-process api
		- fork
		- vfork
		- clone
		- exec(execl, execlp, execle, execv, execvp, execvpe)
		- sched_yield - yield the processor
		- man sched

	* Multi-process communication
		- file
		- sognal
		- semphone
		- socket
		- unix domain socket
		- message queue
		- annoymous pipe
		- named pipe
		- shared memory

### thread [POSIX THREAD](https://zh.wikipedia.org/wiki/POSIX%E7%BA%BF%E7%A8%8B)

> Posts an interrupt request to this Thread. The behavior depends on the state of this Thread:
Threads blocked in one of Object's wait() methods or one of Thread's join() or sleep() methods will be woken up, their interrupt status will be cleared, and they receive an InterruptedException.
Threads blocked in an I/O operation of an java.nio.channels.InterruptibleChannel will have their interrupt status set and receive an java.nio.channels.ClosedByInterruptException. Also, the channel will be closed.
Threads blocked in a java.nio.channels.Selector will have their interrupt status set and return immediately. They don't receive an exception in this case.

	* native posix thread Library (C/C++)
		- pthread_create
		- pthread_exit
		- pthread_cancel
		- pthread_join
		- pthread_kill
		- pthread_cleanup_push
		- pthread_cleanup_pop
		- pthread_setcancelstate
		- pthread_setcanceltype
		- pthread_equal
		- pthread_detach
		- pthread_self
		- pthread_once
		- pthread_attr_*

	* Multi-thread synchronization
	 - mutex：
		* pthread_mutex_init
		* pthread_mutex_destroy
		* pthread_mutex_lock
		* pthread_mutex_trylock
		* pthread_mutex_unlock
		* pthread_mutexattr_*
	- cond
		* pthread_cond_init
		* pthread_cond_destroy
		* pthread_cond_signal
		* pthread_cond_wait
		* pthread_cond_broadcast
		* pthread_condattr_*
	- barrier
		* pthread_barrier_init
		* pthread_barrier_wait
		* pthread_barrier_destory
	- rwlock
		* pthread_rwlock_*
	- semphone
		* sem_open
		* sem_close
		* sem_unlink
		* sem_getvalue
		* sem_wait
		* sem_trywait
		* sem_post
		* sem_init
		* sem_destroy
 
### io multiplexing

	* select
	* poll
	* epoll
