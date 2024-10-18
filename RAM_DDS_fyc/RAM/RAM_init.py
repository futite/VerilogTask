import random

def generate_coe(filename, radix, depth, width, random_data=False, custom_data=None):
    """
    生成 .coe 文件初始化 RAM

    参数:
    - filename: 生成的 .coe 文件名
    - radix: 数据进制，支持 2, 10, 16
    - depth: RAM 深度（即总行数）
    - width: 数据位宽
    - random_data: 是否使用随机数据（如果为 True，忽略 custom_data）
    - custom_data: 用户提供的数据列表（如果有），默认为 None
    """
    
    # 检查 radix 合法性
    if radix not in [2, 10, 16]:
        raise ValueError("radix 只能为 2 (二进制), 10 (十进制), 16 (十六进制)")
    
    # 生成数据
    data_list = []
    if custom_data:
        data_list = custom_data[:depth]  # 如果提供自定义数据，截取到指定深度
    elif random_data:
        # 根据位宽生成随机数据
        max_value = 2 ** width - 1
        if radix == 2:
            data_list = [bin(random.randint(0, max_value))[2:].zfill(width) for _ in range(depth)]
        elif radix == 10:
            data_list = [str(random.randint(0, max_value)) for _ in range(depth)]
        elif radix == 16:
            data_list = [hex(random.randint(0, max_value))[2:].upper().zfill(width // 4) for _ in range(depth)]
    
    # 如果未指定 custom_data 和 random_data，默认全零初始化
    if not custom_data and not random_data:
        if radix == 2:
            data_list = ['0' * width] * depth
        elif radix == 10:
            data_list = ['0'] * depth
        elif radix == 16:
            data_list = ['0' * (width // 4)] * depth
    
    # 生成 .coe 文件
    with open(filename, 'w') as file:
       # file.write(f"memory_initialization_radix = {radix};\n")
       # file.write("memory_initialization_vector =\n")
        for i, data in enumerate(data_list):
            if i == len(data_list) - 1:
                file.write(f"{data};\n")  # 最后一行不要逗号
            else:
                file.write(f"{data}\n")

# 示例用法
depth = 1024   # 16 行数据
width = 32   # 每行 8 位

# 生成十六进制格式的 RAM 初始化文件，使用随机数据
generate_coe("ram_init_random.txt", radix=16, depth=depth, width=width, random_data=True)

# 生成二进制格式的 RAM 初始化文件，使用全零数据
generate_coe("ram_init_zero.coe", radix=2, depth=depth, width=width)

# 生成自定义数据的 RAM 初始化文件
#custom_data = ['FF', '0A', '1B', '2C', '3D', '4E', '5F', '6A', '7B', '8C', '9D', 'AE', 'BF', 'CA', 'DB', 'EC']
#generate_coe("ram_init_custom.coe", radix=16, depth=depth, width=width, custom_data=True)
