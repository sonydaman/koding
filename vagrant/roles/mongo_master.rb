name "mongo_master"
description "The role for MongoDB system master servers"

env_run_lists "prod-sys-b" => ["role[base_server]", "recipe[lvm]", "recipe[mongodb::disks]", "recipe[mongodb]"],
              "prod-sys-a" => ["role[base_server]", "recipe[lvm]", "recipe[mongodb::disks]", "recipe[mongodb]"],
              "prod-sys" => ["role[base_server]", "recipe[lvm]", "recipe[mongodb::disks]", "recipe[mongodb]"],
              "_default" => []

default_attributes({ "mongodb" => {
                                "master" => true,
                                "version" => "2.0.8",
                                "data_device" => "/dev/vg0/fs_mongo_data",
                                "log_device"  => "/dev/vg1/fs_mongo_log",
                                "rest" => true,
                                "dbpath" => "/var/lib/mongodb",
                                "logpath" => "/var/log/mongodb",
                                "admin_user" => 'admin',
                                "repl_user" => 'repl',
                                "admin_pass" => 'cQ7zD43NvLypgGre',
                                "repl_pass" => 'cQdklsdk3e',
                                }
                  })
