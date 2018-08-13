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

custom_target('jump_instruction_tb',
              input : [
                'test/controlpath/jump_instruction_tb.v',
                'src/controlpath/alu_control_word_decoder.v',
                'src/controlpath/alu_control_word_encoder.v',
                'src/controlpath/jump_instruction_decoder.v'
                ],
              output : ['jump_instruction_tb'],
              command : [simulator, '@INPUT@', '-o', '@OUTPUT@'],
              install : true,
              install_dir : ''
  )

custom_target('controlpath_tb',
              input : [
                'test/controlpath/controlpath_tb.v',
                'src/controlpath/alu_control_word_decoder.v',
                'src/controlpath/alu_control_word_encoder.v',
                'src/controlpath/alu_instruction_decoder.v',
                'src/controlpath/control_word_selector.v',
                'src/controlpath/jump_instruction_decoder.v',
                'src/controlpath/null_instruction_decoder.v',
                'src/controlpath.v'
                ],
              output : ['controlpath_tb'],
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

custom_target('flag_tb',
              input : [
                'test/datapath/flag_tb.v',
                'src/datapath/signflag_generator.v',
                'src/datapath/zeroflag_generator.v'
                ],
              output : ['flag_tb'],
              command : [simulator, '@INPUT@', '-o', '@OUTPUT@'],
              install : true,
              install_dir : ''
  )

custom_target('datapath_tb',
              input : [
                'test/datapath/datapath_tb.v',
                'src/datapath/memory.v',
                'src/datapath/alu.v',
                'src/datapath/signflag_generator.v',
                'src/datapath/zeroflag_generator.v',
                'src/components/register_selector.v',
                'src/components/vga_interface.v',
                'src/datapath.v'
                ],
              output : ['datapath_tb'],
              command : [simulator, '@INPUT@', '-o', '@OUTPUT@'],
              install : true,
              install_dir : ''
  )


custom_target('fpga_loader_tb',
              input : [
                'test/fpga_loader_tb.v',
                'src/datapath/memory.v',
                'src/datapath/alu.v',
                'src/datapath/signflag_generator.v',
                'src/datapath/zeroflag_generator.v',
                'src/components/register_selector.v',
                'src/components/hex_decoder.v',
                'src/components/vga_interface.v',
                'src/datapath.v',
                'src/controlpath/alu_control_word_decoder.v',
                'src/controlpath/alu_control_word_encoder.v',
                'src/controlpath/alu_instruction_decoder.v',
                'src/controlpath/control_word_selector.v',
                'src/controlpath/jump_instruction_decoder.v',
                'src/controlpath/null_instruction_decoder.v',
                'src/controlpath.v',
                'src/flow.v',
                'src/fpga_top.v'
                ],
              output : ['fpga_loader_tb'],
              command : [simulator, '@INPUT@', '-o', '@OUTPUT@'],
              install : true,
              install_dir : ''
  )
