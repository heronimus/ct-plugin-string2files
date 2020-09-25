module main

import cli { Command, Flag }
import os
import filewriter

fn main() {
	mut cmd := Command{
		name: 'string2files'
		description: 'Consul-Template plugin that (basically) write string to file(s).'
		version: '0.1.0'
	}
	// CLI Command
	mut append_cmd := Command{
		name: 'append'
		description: 'MODE: Append string to file.'
		usage: '<file-path> <content>'
		required_args: 2
		execute: append_func
	}
	mut create_cmd := Command{
		name: 'create'
		description: 'MODE: Write string to file.'
		usage: '<file-path> <content>'
		required_args: 2
		execute: create_func
	}
	mut explode_cmd := Command{
		name: 'explode'
		description: 'MODE: Split text and write to multiple file.'
		usage: '<base-path> <separator> <content>'
		required_args: 3
		execute: explode_func
	}
	// CLI flags
	mut cli_flags := []Flag{}
	cli_flags << Flag{
		flag: .bool
		name: 'force'
		abbrev: 'f'
		value: 'false'
		description: 'Create new directory/file from <path-file> if not exist.'
	}
	cli_flags << Flag{
		flag: .bool
		name: 'new-line'
		abbrev: 'nl'
		value: 'false'
		description: 'Add new line in the end of file.'
	}
	append_cmd.add_flags(cli_flags)
	create_cmd.add_flags(cli_flags)
	explode_cmd.add_flags(cli_flags)
	// Add command
	cmd.add_command(append_cmd)
	cmd.add_command(create_cmd)
	cmd.add_command(explode_cmd)
	cmd.parse(os.args)
}

fn append_func(cmd Command) {
	flag_force := cmd.flags.get_bool('force') or {
		panic('Failed to get `force` flag: $err')
	}
	flag_newline := cmd.flags.get_bool('new-line') or {
		panic('Failed to get `new-line` flag: $err')
	}
	path := cmd.args[0]
	content := cmd.args[1]
	mut fw := filewriter.FileWriter{
		path: path
		content: content
		is_force: flag_force
		is_newline: flag_newline
	}
	fw.append_file()
}

fn create_func(cmd Command) {
	flag_force := cmd.flags.get_bool('force') or {
		panic('Failed to get `force` flag: $err')
	}
	flag_newline := cmd.flags.get_bool('new-line') or {
		panic('Failed to get `new-line` flag: $err')
	}
	path := cmd.args[0]
	content := cmd.args[1]
	mut fw := filewriter.FileWriter{
		path: path
		content: content
		is_force: flag_force
		is_newline: flag_newline
	}
	fw.create_file()
}

fn explode_func(cmd Command) {
	mut flags := map[string]bool{}
	flags['force'] = cmd.flags.get_bool('force') or {
		panic('Failed to get `force` flag: $err')
	}
	flags['newline'] = cmd.flags.get_bool('new-line') or {
		panic('Failed to get `new-line` flag: $err')
	}
	mut arguments := map[string]string{}
	arguments['basepath'] = cmd.args[0]
	arguments['separator'] = cmd.args[1]
	arguments['content'] = cmd.args[2]
	filewriter.explode_data(arguments, flags)
}
