# Copyright (c) 2017 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

*** Settings ***
| Resource | resources/libraries/robot/performance_setup.robot
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | PDRCHK
| ... | NIC_Intel-X520-DA2 | ETH | IP6FWD | BASE | IP6BASE
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L3 | Intel-X520-DA2
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance pdrchk test
| ...
| Documentation | *Reference PDR throughput IPv6 routing verify test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv6 for IPv6 routing.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with IPv6
| ... | routing and two static IPv6 /64 route entries. DUT1 and DUT2 tested with
| ... | 2p10GE NIC X520 Niantic by Intel.
| ... | *[Ver] TG verification:* In short performance tests, TG verifies
| ... | DUTs' throughput at ref-PDR (reference Non Drop Rate) with zero packet
| ... | loss tolerance. Ref-PDR value is periodically updated acording to
| ... | formula: ref-PDR = 0.9x PDR, where PDR is found in RFC2544 long
| ... | performance tests for the same DUT configuration. Test packets are
| ... | generated by TG on links to DUTs. TG traffic profile contains two L3
| ... | flow-groups (flow-group per direction, 253 flows per flow-group) with
| ... | all packets containing Ethernet header, IPv6 header and static
| ... | payload. MAC addresses are matching MAC addresses of the TG node
| ... | interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
# Traffic profile:
| ${traffic_profile} | trex-sl-3n-ethip6-ip6src253

*** Keywords ***
| Check PDR for IPv6 routing
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with ${wt} thread, ${wt} phy core,\
| | ... | ${rxq} receive queue per NIC port.
| | ... | [Ver] Verify ref-NDR for ${framesize} Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Arguments] | ${framesize} | ${rate} | ${wt} | ${rxq}
| | ...
| | # Test Variables required for test and test teardown
| | Set Test Variable | ${framesize}
| | Set Test Variable | ${rate}
| | ${get_framesize}= | Get Frame Size | ${framesize}
| | ...
| | Given Add '${wt}' worker threads and '${rxq}' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Run Keyword If | ${get_framesize} < ${1522}
| | ... | Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding in 3-node circular topology
| | Then Traffic should pass with partial loss | ${perf_trial_duration}
| | ... | ${rate} | ${framesize} | ${traffic_profile}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

*** Test Cases ***
| tc01-78B-1t1c-ethip6-ip6base-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-NDR for 78 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 78B | 1T1C | STHREAD
| | ...
| | [Template] | Check PDR for IPv6 routing
| | framesize=${78} | rate=3.9mpps | wt=1 | rxq=1

| tc02-1518B-1t1c-ethip6-ip6base-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-NDR for 1518 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 1518B | 1T1C | STHREAD
| | ...
| | [Template] | Check PDR for IPv6 routing
| | framesize=${1518} | rate=400000pps | wt=1 | rxq=1

| tc03-9000B-1t1c-ethip6-ip6base-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-NDR for 9000 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 9000B | 1T1C | STHREAD
| | ...
| | [Template] | Check PDR for IPv6 routing
| | framesize=${9000} | rate=60000pps | wt=1 | rxq=1

| tc04-78B-2t2c-ethip6-ip6base-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 2 threads, 2 phy cores,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-NDR for 78 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 78B | 2T2C | MTHREAD
| | ...
| | [Template] | Check PDR for IPv6 routing
| | framesize=${78} | rate=6.0mpps | wt=2 | rxq=1

| tc05-1518B-2t2c-ethip6-ip6base-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 2 threads, 2 phy cores,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-NDR for 1518 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 1518B | 2T2C | MTHREAD
| | ...
| | [Template] | Check PDR for IPv6 routing
| | framesize=${1518} | rate=400000pps | wt=2 | rxq=1

| tc06-9000B-2t2c-ethip6-ip6base-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 2 threads, 2 phy cores,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-NDR for 9000 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 9000B | 2T2C | MTHREAD
| | ...
| | [Template] | Check PDR for IPv6 routing
| | framesize=${9000} | rate=60000pps | wt=2 | rxq=1

| tc07-78B-4t4c-ethip6-ip6base-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 4 threads, 4 phy cores,\
| | ... | 2 receive queues per NIC port.
| | ... | [Ver] Verify ref-NDR for 78 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 78B | 4T4C | MTHREAD
| | ...
| | [Template] | Check PDR for IPv6 routing
| | framesize=${78} | rate=6.1mpps | wt=4 | rxq=2

| tc08-1518B-4t4c-ethip6-ip6base-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 4 threads, 4 phy cores,\
| | ... | 2 receive queues per NIC port.
| | ... | [Ver] Verify ref-NDR for 1518 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 1518B | 4T4C | MTHREAD
| | ...
| | [Template] | Check PDR for IPv6 routing
| | framesize=${1518} | rate=400000pps | wt=4 | rxq=2

| tc09-9000B-4t4c-ethip6-ip6base-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 4 threads, 4 phy cores,\
| | ... | 2 receive queues per NIC port.
| | ... | [Ver] Verify ref-NDR for 9000 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 9000B | 4T4C | MTHREAD
| | ...
| | [Template] | Check PDR for IPv6 routing
| | framesize=${9000} | rate=60000pps | wt=4 | rxq=2
