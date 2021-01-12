/*************************************************************************
	> File Name: global.cpp
	> Author: fuyinglong
	> Mail: 838106527@qq.com
	> Created Time: Wed Oct 21 16:44:19 2020
 ************************************************************************/

#include "global.h"

unordered_map<string,int> name_sock_map;
unordered_map<int,set<int>> group_map;
unordered_map<string,string> from_to_map;//key:用户名 value:key的用户想私聊的用户
time_point<system_clock> begin_clock;
//clock_t begin_clock;//开始时间，用于性能测试
int total_handle;//总处理请求数，用于性能测试
