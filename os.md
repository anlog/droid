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
