#include <iostream>
#include <string>
#include <vector>
#include "ByteStream.h"
#include "tinyfiledialogs.h"
#include <fstream>
#include <sstream>

int prog_en() {
	system("cls");
	std::cout << "MHAT Compressor Program v1.0.0" << std::endl << std::endl;

	std::vector<std::string> filePaths;
	std::string awesomeFiles = tinyfd_openFileDialog("Adding file ", 0, 0, 0, "Any File", 1);

	std::stringstream ss(awesomeFiles);
	std::string segment;
	while (std::getline(ss, segment, '|'))
		filePaths.push_back(segment);

	for (int i = 0; i < filePaths.size(); i++)
		std::cout << i << ": " << filePaths[i] << std::endl;
	int fileCount = filePaths.size();

	system("cls");
	std::cout << "MHAT Compressor Program v1.0.0" << std::endl << std::endl;

	const char* bruhhh[1] = { "*.mhat" };
	std::ofstream outputArchive(tinyfd_saveFileDialog("MHAT Compressor", "output.mhat", 1, bruhhh, "Mushroom Head Archive Type (*.mhat)"), std::ios::binary | std::ios::ate);
	if (!outputArchive.is_open() || outputArchive.fail())
		return 0;

	outputArchive << "MHAT";

	ByteStream awesomeBytes(28);
	awesomeBytes << (unsigned short)65534;
	awesomeBytes << (unsigned short)1;
	awesomeBytes << (unsigned short)fileCount;

	char* outBuf = new char[28];
	unsigned char* bruhhhh = new unsigned char[28];
	unsigned int superlength = awesomeBytes.getBuf(bruhhhh);
	for (int i = 0; i < 28; i++)
		outBuf[i] = i >= superlength ? 0 : bruhhhh[i];
	outputArchive.write(outBuf, 28);

	std::cout << "We've got ";
	for (int i = 0; i < fileCount; i++) {
		if (i == fileCount - 1)
			std::cout << "& " << filePaths[i] << "." << std::endl;
		else
			std::cout << filePaths[i] << ", ";

		std::string base_filename = filePaths[i].substr(filePaths[i].find_last_of("/\\") + 1);


		std::ifstream inputFile(filePaths[i], std::ios::binary | std::ios::ate);
		inputFile.seekg(0, std::ios::end);
		const unsigned int ifBufSize = ((unsigned int)inputFile.tellg() + 1);
		inputFile.seekg(0, std::ios::beg);
		unsigned char* mcbrrrrr = new unsigned char[ifBufSize];
		inputFile.read((char*)mcbrrrrr, ifBufSize);
		inputFile.close();

		const unsigned int bigLength = base_filename.length() + sizeof(unsigned int) + ifBufSize;
		ByteStream awesomeBytes_2(bigLength);
		awesomeBytes_2 << base_filename.c_str();
		awesomeBytes_2 << (unsigned int)(ifBufSize - 1);
		for (int i = 0; i < ifBufSize; i++)
			awesomeBytes_2 << mcbrrrrr[i];

		outBuf = new char[bigLength];
		bruhhhh = new unsigned char[bigLength];
		superlength = awesomeBytes_2.getBuf(bruhhhh);
		for (int i = 0; i < superlength; i++)
			outBuf[i] = bruhhhh[i];
		outputArchive.write(outBuf, bigLength);
	}

	outputArchive.close();
	return 0;
}

int prog_de() {
	system("cls");
	std::cout << "MHAT Decompressor Program v1.0.0" << std::endl << std::endl;
	return 0;
}

int main(int argc, const char* argv[]) {
	system("cls");
	std::cout << "MHAT Compressor/Decompressor Program v1.0.0" << std::endl << std::endl;

	/*for (int i = 0; i < argc; i++) {
		std::cout << "Argument " << i << " = " << argv[i] << std::endl;
	}*/

	char mode = 0;
	std::cout << "What do you want to do? [C = Compress, D = Decompress]" << std::endl << "Mode: ";
	std::cin >> mode;
	std::cout << std::endl;

	switch (mode) {
		case 'c':
		case 'C':
			return prog_en();
		case 'd':
		case 'D':
			return prog_de();
	}

	std::cout << std::endl << "Invalid mode \"" << mode << "\". Terminating process." << std::endl;
	return 0;
}