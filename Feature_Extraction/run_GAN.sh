cd /mnt/rstor/CSE_BME_AXM788/home/hxl735/models/multi_wsi_submit/GAN_package
data_path='/home/hxl735/matlab_code/tempt/'
save_path='/home/hxl735/matlab_code/tempt/'
python2 test.py --trained_model '/home/zxz833/segmentation_byzzlv7/checkpoints/BEP_seg/latest_net_G.pth' --image_size 2048 --dataroot $data_path --results_dir $save_path
