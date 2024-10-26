module filewriter

import os
import log

pub struct FileWriter {
mut:
	ofile  os.File
pub mut:
	path       string
	content    string
	is_force   bool
	is_newline bool
	logger log.Log = log.Log{}
}
