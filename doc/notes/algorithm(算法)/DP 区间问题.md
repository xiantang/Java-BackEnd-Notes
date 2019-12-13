我们主要通过三道子序列问题来分析
首先DP区间问题可以通过大问题划分成最优的子结构来解决。
也就是说每个最终解都是从子问题开始的。

* 516.longest-palindromic-subsequence
    Given a string s, find the longest palindromic subsequence's length in s.
    我们采用一个二维的数组来记录历史，`dp[i][j]`表示的是索引`i`-`j`之间的最大字串。
    我们可以发现下面三个情况:
    * len=1 的时候表示`dp[i][j]`就只有一个字符，`dp[i][j]=1`
    * `str[i]==str[j]`就表示是回文，`dp[i][j] = dp[i+1][j-1]+2`
    * 否则不是在前就是在后。
    
    针对如何遍历所有序列我们采用这样的方式
    ```java
    for(int len=1;len<=s.length();len++){
            // 起始位置
            for(int i=0;i<=s.length()-len;i++){
                // j的位置
                int j = i+len-1;
            // do something
            }
    }
    ```
    