project('deepflow')

simulator = find_program('iverilog')

custom_target('alu_tb',
              input : ['test/datapath/alu_tb.v', 'src/datapath/alu.v'],
              output : ['alu_tb'],
              command : [simulator, '@INPUT@', '-o', '@OUTPUT@'],
              install : true,
              install_dir : ''
  )
