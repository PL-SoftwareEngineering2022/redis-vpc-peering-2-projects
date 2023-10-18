# redis-vpc-peering-2-projects
- This project will allow users to access the redis instance from two different projects.
- To configure the access VMs:
  - `sudo apt-get` update on all the VMS
  - `sudo apt-get install redis tools` on all the redis-access VMs
  - On the redis-proxy VM, we need to install `nutcracker`:
  -   `sudo apt-get install nutcracker`
-   then we need to write a nutcracker.yaml which will be the configuration file pointing to the REDIS instance. I prefer to store this configuration file in the /etc folder so that it is not accidentally deleted.
-   nutcracker.yaml
  ```
<redis instance name>:
 listen: 0.0.0.0:6379
 redis: true
 servers:
 - [REDIS-1 IP]:6379:1
```
- to start the nutcracker application:
  - `sudo nutcracker --conf-file <path-to-nutcracker.yaml>
