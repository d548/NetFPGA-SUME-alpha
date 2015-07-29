#!/bin/sh


echo "****************************************"
echo "===> IF0"
echo "****************************************"


echo "===> SUME_NF_10G_INTERFACE0_BASEADDR (0x44040000)"
echo -n "SUME_NF_10G_INTERFACE_SHARED_PKTIN_0_OFFSET: "
./rwaxi -a 0x44040014
echo -n "SUME_NF_10G_INTERFACE_SHARED_PKTOUT_0_OFFSET: "
./rwaxi -a 0x44040018

echo "****************************************"
echo "===> IF1"
echo "****************************************"


echo "===> SUME_NF_10G_INTERFACE1_BASEADDR (0x44050000)"
echo -n "SUME_NF_10G_INTERFACE_PKTIN_0_OFFSET: "
./rwaxi -a 0x44050014
echo -n "SUME_NF_10G_INTERFACE_PKTOUT_0_OFFSET: "
./rwaxi -a 0x44050018

echo "****************************************"
echo "===> IF2"
echo "****************************************"


echo "===> SUME_NF_10G_INTERFACE2_BASEADDR (0x44060000)"
echo -n "SUME_NF_10G_INTERFACE_PKTIN_0_OFFSET: "
./rwaxi -a 0x44060014
echo -n "SUME_NF_10G_INTERFACE_PKTOUT_0_OFFSET: "
./rwaxi -a 0x44060018

echo "****************************************"
echo "===> IF3"
echo "****************************************"


echo "===> SUME_NF_10G_INTERFACE3_BASEADDR (0x44070000)"
echo -n "SUME_NF_10G_INTERFACE_PKTIN_0_OFFSET: "
./rwaxi -a 0x44070014
echo -n "SUME_NF_10G_INTERFACE_PKTOUT_0_OFFSET: "
./rwaxi -a 0x44070018

echo "****************************************"
echo "===> IA"
echo "****************************************"


echo -n "SUME_INPUT_ARBITER_PKTIN_0_OFFSET: "
./rwaxi -a 0x44010010
echo -n "SUME_INPUT_ARBITER_PKTOUT_0_OFFSET: "
./rwaxi -a 0x44010014

echo "****************************************"
echo "===> OPL"
echo "****************************************"

echo "===> SUME_OUTPUT_PORT_LOOKUP_BASEADDR (0x44030000)"
echo -n "SUME_OUTPUT_PORT_LOOKUP_PKTIN_0_OFFSET: "
./rwaxi -a 0x44020010
echo -n "SUME_OUTPUT_PORT_LOOKUP_PKTOUT_0_OFFSET: "
./rwaxi -a 0x44020014
echo -n "SUME_OUTPUT_PORT_LOOKUP_LUTHIT_0: "
./rwaxi -a 0x44020018
echo -n "SUME_OUTPUT_PORT_LOOKUP_LUTMISS_0: "
./rwaxi -a 0x4402001c




echo "****************************************"
echo "===> SUME_OUTPUT_QUEUES_0"
echo "****************************************"
echo -n "SUME_OUTPUT_QUEUES_PKTIN_0_OFFSET: "
./rwaxi -a 0x44030010
echo -n "SUME_OUTPUT_QUEUES_PKTOUT_0_OFFSET: "
./rwaxi -a 0x44030014
echo -n "SUME_OUTPUT_QUEUES_PKTSTOREDPORT0_0_OFFSET: "
./rwaxi -a 0x44030018
echo -n "SUME_OUTPUT_QUEUES_BYTESSTOREDPORT0_0_OFFSET: "
./rwaxi -a 0x4403001c
echo -n "SUME_OUTPUT_QUEUES_PKTREMOVEDPORT0_0_OFFSET: "
./rwaxi -a 0x44030020
echo -n "SUME_OUTPUT_QUEUES_BYTESREMOVEDPORT0_0_OFFSET: "
./rwaxi -a 0x44030024
echo -n "SUME_OUTPUT_QUEUES_PKTDROPPEDPORT0_0_OFFSET: "
./rwaxi -a 0x44030028
echo -n "SUME_OUTPUT_QUEUES_BYTESDROPPEDPORT0_0_OFFSET: "
./rwaxi -a 0x4403002c
echo -n "SUME_OUTPUT_QUEUES_PKTINQUEUEPORT0_0_OFFSET: "
./rwaxi -a 0x44030030


echo "****************************************"
echo "===> SUME_OUTPUT_QUEUES_1"
echo "****************************************"
echo -n "SUME_OUTPUT_QUEUES_PKTSTOREDPORT1_0_OFFSET: "
./rwaxi -a 0x44030034
echo -n "SUME_OUTPUT_QUEUES_BYTESSTOREDPORT1_0_OFFSET: "
./rwaxi -a 0x44030038
echo -n "SUME_OUTPUT_QUEUES_PKTREMOVEDPORT1_0_OFFSET: "
./rwaxi -a 0x4403003c
echo -n "SUME_OUTPUT_QUEUES_BYTESREMOVEDPORT1_0_OFFSET: "
./rwaxi -a 0x44030040
echo -n "SUME_OUTPUT_QUEUES_PKTDROPPEDPORT1_0_OFFSET: "
./rwaxi -a 0x44030044
echo -n "SUME_OUTPUT_QUEUES_BYTESDROPPEDPORT1_0_OFFSET: "
./rwaxi -a 0x44030048
echo -n "SUME_OUTPUT_QUEUES_PKTINQUEUEPORT1_0_OFFSET: "
./rwaxi -a 0x4403004c


echo "****************************************"
echo "===> SUME_OUTPUT_QUEUES_2"
echo "****************************************"
echo -n "SUME_OUTPUT_QUEUES_PKTSTOREDPORT2_0_OFFSET: "
./rwaxi -a 0x44030050
echo -n "SUME_OUTPUT_QUEUES_BYTESSTOREDPORT2_0_OFFSET: "
./rwaxi -a 0x44030054
echo -n "SUME_OUTPUT_QUEUES_PKTREMOVEDPORT2_0_OFFSET: "
./rwaxi -a 0x44030058
echo -n "SUME_OUTPUT_QUEUES_BYTESREMOVEDPORT2_0_OFFSET: "
./rwaxi -a 0x4403005c
echo -n "SUME_OUTPUT_QUEUES_PKTDROPPEDPORT2_0_OFFSET: "
./rwaxi -a 0x44030060
echo -n "SUME_OUTPUT_QUEUES_BYTESDROPPEDPORT2_0_OFFSET: "
./rwaxi -a 0x44030064
echo -n "SUME_OUTPUT_QUEUES_PKTINQUEUEPORT2_0_OFFSET: "
./rwaxi -a 0x44030068

echo "****************************************"
echo "===> SUME_OUTPUT_QUEUES_3"
echo "****************************************"
echo -n "SUME_OUTPUT_QUEUES_PKTSTOREDPORT3_0_OFFSET: "
./rwaxi -a 0x4403006c
echo -n "SUME_OUTPUT_QUEUES_BYTESSTOREDPORT3_0_OFFSET: "
./rwaxi -a 0x44030070
echo -n "SUME_OUTPUT_QUEUES_PKTREMOVEDPORT3_0_OFFSET: "
./rwaxi -a 0x44030074
echo -n "SUME_OUTPUT_QUEUES_BYTESREMOVEDPORT3_0_OFFSET: "
./rwaxi -a 0x44030078
echo -n "SUME_OUTPUT_QUEUES_PKTDROPPEDPORT3_0_OFFSET: "
./rwaxi -a 0x4403007c
echo -n "SUME_OUTPUT_QUEUES_BYTESDROPPEDPORT3_0_OFFSET: "
./rwaxi -a 0x44030080
echo -n "SUME_OUTPUT_QUEUES_PKTINQUEUEPORT3_0_OFFSET: "
./rwaxi -a 0x44030084

echo "****************************************"
echo "===> SUME_OUTPUT_QUEUES_4"
echo "****************************************"
echo -n "SUME_OUTPUT_QUEUES_PKTSTOREDPORT4_0_OFFSET: "
./rwaxi -a 0x44030088
echo -n "SUME_OUTPUT_QUEUES_BYTESSTOREDPORT4_0_OFFSET: "
./rwaxi -a 0x4403008c
echo -n "SUME_OUTPUT_QUEUES_PKTREMOVEDPORT4_0_OFFSET: "
./rwaxi -a 0x44030090
echo -n "SUME_OUTPUT_QUEUES_BYTESREMOVEDPORT4_0_OFFSET: "
./rwaxi -a 0x44030094
echo -n "SUME_OUTPUT_QUEUES_PKTDROPPEDPORT4_0_OFFSET: "
./rwaxi -a 0x44030098
echo -n "SUME_OUTPUT_QUEUES_BYTESDROPPEDPORT4_0_OFFSET: "
./rwaxi -a 0x4403009c
echo -n "SUME_OUTPUT_QUEUES_PKTINQUEUEPORT4_0_OFFSET: "
./rwaxi -a 0x440300a0

#echo "===> SUME_NF_RIFFA_DMA_BASEADDR (0x44080000)"
#echo -n "SUME_NF_RIFFA_DMA_ID_0_OFFSET: "
#./rwaxi -a 0x44080000
#echo -n "SUME_NF_RIFFA_DMA_VERSION_0_OFFSET: "
#./rwaxi -a 0x44080004
#echo -n "SUME_NF_RIFFA_DMA_FLIP_0_OFFSET: "
#./rwaxi -a 0x44080008
#echo -n "SUME_NF_RIFFA_DMA_DEBUG_0_OFFSET: "
#./rwaxi -a 0x4408000c
#echo -n "SUME_NF_RIFFA_DMA_RQPKT_0_OFFSET: "
#./rwaxi -a 0x44080010
#echo -n "SUME_NF_RIFFA_DMA_RCPKT_0_OFFSET: "
#./rwaxi -a 0x44080014
#echo -n "SUME_NF_RIFFA_DMA_CQPKT_0_OFFSET: "
#./rwaxi -a 0x44080018
#echo -n "SUME_NF_RIFFA_DMA_CCPKT_0_OFFSET: "
#./rwaxi -a 0x4408001c
#echo -n "SUME_NF_RIFFA_DMA_XGETXPKT_0_OFFSET: "
#./rwaxi -a 0x44080020
#echo -n "SUME_NF_RIFFA_DMA_XGERXPKT_0_OFFSET: "
#./rwaxi -a 0x44080024
#echo -n "SUME_NF_RIFFA_DMA_PCIERQ_0_OFFSET: "
#./rwaxi -a 0x44080028
#echo -n "SUME_NF_RIFFA_DMA_PCIEPHY_0_OFFSET: "
#./rwaxi -a 0x4408002c
#echo -n "SUME_NF_RIFFA_DMA_PCIECONFIG_0_OFFSET: "
#./rwaxi -a 0x44080030
#echo -n "SUME_NF_RIFFA_DMA_PCIECONFIG2_0_OFFSET: "
#./rwaxi -a 0x44080034
#echo -n "SUME_NF_RIFFA_DMA_PCIEERROR_0_OFFSET: "
#./rwaxi -a 0x44080038
#echo -n "SUME_NF_RIFFA_DMA_PCIEMISC_0_OFFSET: "
#./rwaxi -a 0x4408003c
#echo -n "SUME_NF_RIFFA_DMA_PCIETPH_0_OFFSET: "
#./rwaxi -a 0x44080040
#echo -n "SUME_NF_RIFFA_DMA_PCIEFC1_0_OFFSET: "
#./rwaxi -a 0x44080044
#echo -n "SUME_NF_RIFFA_DMA_PCIEFC2_0_OFFSET: "
#./rwaxi -a 0x44080048
#echo -n "SUME_NF_RIFFA_DMA_PCIEFC3_0_OFFSET: "
#./rwaxi -a 0x4408004c
#echo -n "SUME_NF_RIFFA_DMA_PCIEINTERRUPT_0_OFFSET: "
#./rwaxi -a 0x44080050
#echo -n "SUME_NF_RIFFA_DMA_PCIEMSIDATA_0_OFFSET: "
#./rwaxi -a 0x44080054
#echo -n "SUME_NF_RIFFA_DMA_PCIEMSIINT_0_OFFSET: "
#./rwaxi -a 0x44080058
#echo -n "SUME_NF_RIFFA_DMA_PCIEMSIPENDINGSTATUS_0_OFFSET: "
#./rwaxi -a 0x4408005c
#echo -n "SUME_NF_RIFFA_DMA_PCIEMSIPENDINGSTATUS2_0_OFFSET: "
#./rwaxi -a 0x44080060
#echo -n "SUME_NF_RIFFA_DMA_PCIEINTERRUPT2_0_OFFSET: "
#echo -n "SUME_OUTPUT_QUEUES_ID_0_OFFSET: "
