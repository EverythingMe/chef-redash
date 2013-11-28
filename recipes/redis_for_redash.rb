#
# Cookbook Name:: redash
# Recipe:: redis_for_redash
# 
# installs redis-server
#


# This is really simple.
# This recipe provides simplistic default installation of redis
# 
# Contrast this to the full-fledged opscode cookbook redisio

package 'redis-server'
