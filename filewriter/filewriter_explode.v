module filewriter

pub fn explode_data(args map[string]string, flags map[string]bool) {
	mut fw := FileWriter{
		is_force: flags['force']
		is_newline: flags['newline']
	}
	// Split data by separator (bugs on multi char separator)
	mut content_split := args['content'].split(args['separator'])
	if content_split.len == 0 {
		fw.logger.error('KV not found after spliting with separator.')
		exit(1)
	}
	if content_split.len % 2 != 0 {
		fw.logger.warn('(${content_split}) k/v pair is not even, ommiting uncomplete k/v.')
		content_split = content_split[0..(content_split.len - 1)]
	}
	// Loops splited data
	for i := 0; i < content_split.len; i += 2 {
		if content_split[i] == '' {
			fw.logger.warn('path is empty, skipping')
			continue
		}
		fw.logger.info('path --> ${content_split[i]}')
		fw.path = args['basepath'] + '/' + content_split[i]
		fw.content = content_split[i + 1]
		fw.create_file()
	}
}
