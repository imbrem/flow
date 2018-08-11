project('deepflow')

simulator = find_program('iverilog')

custom_target('alu_tb',
              input : ['test/datapath/alu_tb.v', 'src/datapath/alu.v'],
              output : ['alu_tb'],
              command : [simulator, '@INPUT@', '-o', '@OUTPUT@'],
              install : true,
              install_dir : ''
  )

custom_target('null_instruction_tb',
              input : [
                'test/controlpath/null_instruction_tb.v',
                'src/controlpath/alu_control_word_decoder.v',
                'src/controlpath/alu_control_word_encoder.v',
                'src/controlpath/null_instruction_decoder.v'
                ],
              output : ['null_instruction_tb'],
              command : [simulator, '@INPUT@', '-o', '@OUTPUT@'],
              install : true,
              install_dir : ''
  )

custom_target('memory_tb',
              input : [
                'test/datapath/memory_tb.v',
                'src/datapath/memory.v'
                ],
              output : ['memory_tb'],
              command : [simulator, '@INPUT@', '-o', '@OUTPUT@'],
              install : true,
              install_dir : ''
  )
