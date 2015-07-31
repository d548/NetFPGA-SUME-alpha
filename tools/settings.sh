export SUME_FOLDER=${HOME}/NetFPGA-SUME-alpha
export XILINX_PATH=/opt/Xilinx/Vivado/2014.4
export NF_PROJECT_NAME=reference_switch
export PROJECTS=${SUME_FOLDER}/projects
export DEV_PROJECTS=${SUME_FOLDER}/dev-projects
export IP_FOLDER=${SUME_FOLDER}/lib/hw/std/cores
export CONSTRAINTS=${SUME_FOLDER}/lib/hw/std/constraints
export XILINX_IP_FOLDER=${SUME_FOLDER}/lib/hw/xilinx/cores
export NF_DESIGN_DIR=${SUME_FOLDER}/projects/${NF_PROJECT_NAME}
export NF_WORK_DIR=/tmp/${USER}
export PYTHONPATH=.:${SUME_FOLDER}/tools/scripts/:${NF_DESIGN_DIR}/lib/Python:${SUME_FOLDER}/tools/scripts/NFTest
export DRIVER_NAME=sume_riffa_v1_0_0
export DRIVER_FOLDER=${SUME_FOLDER}/lib/sw/std/driver/${DRIVER_NAME}
export APPS_FOLDER=${SUME_FOLDER}/lib/sw/std/apps/${DRIVER_NAME}

