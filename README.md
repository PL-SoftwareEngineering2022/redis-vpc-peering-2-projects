# redis-vpc-peering-2-projects
- This project will allow users to access the redis instance from two different projects. Since we always want the data to be behind internal IPs, I have configured a nat router to allow internet access for package updates and installation of necessary tools
- To configure the access VMs:
  - `sudo apt-get update` on all the VMS
  - `sudo apt-get install redis-tools` on all the redis-access VMs
  - On the redis-proxy VM, we need to install `nutcracker`:
  -   `sudo apt-get install nutcracker`
-   Then we need to write a nutcracker.yaml which will be the configuration file pointing to the REDIS instance. I prefer to store this configuration file in the /etc folder so that it is not accidentally deleted.
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
- When you ssh into the access VM on project2, you can access the redis instance by using the redis-proxy to tunnel into it:
  - `redis-cli -h <redis-proxy-IP>`
- On project1 you can decide to tunnel through the redis-proxy or tunnel to the redis instance directly
- To test the connection:
  - You can set, get and delete a key:
  - For example: set team "new team"
  - get team
  - del team
