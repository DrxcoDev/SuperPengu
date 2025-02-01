#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <regex>
#include <unordered_map>

void processPenguFile(const std::string& filename) {
    std::ifstream inputFile(filename);
    
    if (!inputFile.is_open()) {
        std::cerr << "No se pudo abrir el archivo: " << filename << std::endl;
        return;
    }

    std::stringstream buffer;
    buffer << inputFile.rdbuf();
    std::string content = buffer.str();

    std::cout << "Contenido del archivo:\n" << content << "\n";  // Agregado para depuraci�n

    // Regex para encontrar el bloque de configuraciones
    std::regex configBlockRegex(R"(\{(.+?)\})", std::regex_constants::extended | std::regex_constants::multiline);
    std::smatch configMatch;

    if (std::regex_search(content, configMatch, configBlockRegex)) {
        std::string configContent = configMatch[1];

        std::cout << "Bloque de configuraciones encontrado:\n" << configContent << "\n";  // Agregado para depuraci�n

        // Regex para buscar configuraciones dentro del bloque
        std::regex keyValueRegex(R"(\s*(\w+)\s*=\s*([^\s;]+)\s*;)");
        std::unordered_map<std::string, std::string> configurations;

        auto configBegin = std::sregex_iterator(configContent.begin(), configContent.end(), keyValueRegex);
        auto configEnd = std::sregex_iterator();

        // Verificaci�n de las configuraciones encontradas
        bool foundConfigs = false;
        for (std::sregex_iterator i = configBegin; i != configEnd; ++i) {
            std::string key = (*i)[1].str();
            std::string value = (*i)[2].str();
            configurations[key] = value;
            std::cout << "Configuraci�n encontrada: " << key << " = " << value << std::endl;
            foundConfigs = true;
        }

        if (!foundConfigs) {
            std::cerr << "No se encontraron configuraciones v�lidas dentro del bloque." << std::endl;
            return;
        }

        // Abrir el archivo de configuraci�n para escritura
        std::ofstream outFile("env/usr/conf/pengu.conf");

        if (!outFile.is_open()) {
            std::cerr << "No se pudo abrir el archivo de salida para escribir." << std::endl;
            return;
        }

        // Escribir las configuraciones en el archivo de configuraci�n
        std::cout << "Escribiendo en pengu.conf..." << std::endl;
        for (const auto& [key, value] : configurations) {
            outFile << key << "=" << value << "\n";
            std::cout << "Guardado: " << key << "=" << value << " en pengu.conf" << std::endl;
        }

        outFile.close();
        std::cout << "Archivo 'pengu.conf' guardado correctamente." << std::endl;
    } else {
        std::cerr << "No se encontr� el bloque de configuraciones en el archivo." << std::endl;
    }
}

int main() {
    std::string filename = "config.pengu"; // Archivo de entrada
    processPenguFile(filename);
    return 0;
}