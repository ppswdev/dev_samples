import UIKit
import MSGraphClientModels
import MSAL

class OneDriveManageViewController: UIViewController {
    
    /// 记录文件夹的项
    var folderCounts = [String:Int]()
    
    var dataArray = [NSDictionary]()
    var selectedFiles = Set<NSDictionary>()
    var tableView: UITableView!
    var stacks = [(path: "root/children",name: "MyDrive")]
    var breadcrumbStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupNavigationBar()
        setupBreadcrumbStackView()
        setupTableView()
        
        loadFiles()
    }

    func setupNavigationBar() {
        self.navigationItem.title = "OneDrive"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectAllFiles))
    }

    func setupBreadcrumbStackView() {
        breadcrumbStackView = UIStackView()
        breadcrumbStackView.backgroundColor = .clear
        breadcrumbStackView.axis = .horizontal
        breadcrumbStackView.alignment = .leading
        breadcrumbStackView.spacing = 2
        breadcrumbStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(breadcrumbStackView)
        
        NSLayoutConstraint.activate([
            breadcrumbStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            breadcrumbStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            breadcrumbStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -15),
            breadcrumbStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomFileCell.self, forCellReuseIdentifier: "CustomFileCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        
        // Add download button
        let downloadButton = UIButton(type: .system)
        downloadButton.backgroundColor = .orange
        downloadButton.setTitle("Download Selected Files", for: .normal)
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadSelectedFiles), for: .touchUpInside)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.layer.cornerRadius = 25
        self.view.addSubview(downloadButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: breadcrumbStackView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: downloadButton.topAnchor, constant: -10),
            
            downloadButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            downloadButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            downloadButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            downloadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func updateBreadcrumb() {
        breadcrumbStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, file) in stacks.enumerated() {
            let label = ClickableLabel()
            label.text = file.name
            label.textColor = index == stacks.count - 1 ? .gray : .blue
            label.onClick = { [weak self] in
                guard let self = self else{return}
                self.goFolder(index: index)
            }
            breadcrumbStackView.addArrangedSubview(label)
            
            if index < stacks.count - 1 {
                let separator = UILabel()
                separator.text = ">"
                separator.textColor = .gray
                breadcrumbStackView.addArrangedSubview(separator)
            }
        }
    }
    
    func loadFiles() {
        guard let path = stacks.last?.path else{return}
        print("current load : \(stacks.last!)")
        
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/drive/\(path)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(CloudDriveManager.shared.msalAccessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to list files: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data found.")
                return
            }
            
            do {
                let collection = try MSCollection(data: data)
                guard let dictionaries = collection.value as? [NSDictionary] else {
                    print("Failed to parse files as NSDictionary.")
                    return
                }
                
                self.dataArray = dictionaries
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateBreadcrumb()
                }
            } catch {
                print("Failed to parse response: \(error)")
            }
        }
        task.resume()
    }

    /// 未使用
    func getFolderDetails(id: String, folderPath: String) {
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/drive/items/\(id)/children")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(CloudDriveManager.shared.msalAccessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to list folder: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data found.")
                return
            }
            
            do {
                let collection = try MSCollection(data: data)
                guard let files = collection.value as? [MSGraphDriveItem] else {
                    print("No files found.")
                    return
                }
                
                var fileCount = 0
                var folderCount = 0

                for file in files {
                    if file.folder != nil {
                        folderCount += 1
                    } else {
                        fileCount += 1
                    }
                }
                self.folderCounts[id] = folderCount + fileCount
                print("Folder path: \(folderPath)")
                print("Total files: \(fileCount)")
                print("Total folders: \(folderCount)")
                print("folderCounts: \(id) : \(self.folderCounts[id] ?? 0)")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Failed to parse response: \(error)")
            }
        }
        task.resume()
    }
    
    func downloadFile(file: NSDictionary, to destinationURL: URL) {
        guard let fileId = file["id"] as? String else{return}
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/drive/items/\(fileId)/content")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(CloudDriveManager.shared.msalAccessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.downloadTask(with: request) { (tempURL, response, error) in
            if let error = error {
                print("Failed to download file: \(error)")
                return
            }
            
            guard let tempURL = tempURL else {
                print("No data found.")
                return
            }
            
            do {
                let data = try Data(contentsOf: tempURL)
                try data.write(to: destinationURL)
                print("Downloaded file to: \(destinationURL)")
            } catch {
                print("Failed to write file: \(error)")
            }
        }
        task.resume()
    }

    func downloadFolder(folder: NSDictionary, to destinationURL: URL) {
        guard let foldId = folder["id"] as? String, let foldName = folder["name"] as? String else{return}
        let folderPath = foldName
        let destinationFolderURL = destinationURL.appendingPathComponent(folderPath)
        
        do {
            try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error)")
            return
        }
        
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/drive/items/\(foldId)/children")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(CloudDriveManager.shared.msalAccessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Failed to list folder: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data found.")
                return
            }
            
            do {
                let collection = try MSCollection(data: data)
                guard let files = collection.value as? [NSDictionary] else {
                    print("No files found.")
                    return
                }
                
                for file in files {
                    guard let keys = file.allKeys as? [String], let fileName = file["name"] as? String else{continue}
                    if keys.contains(where: {$0 == "folder"}) {
                        self.downloadFolder(folder: file, to: destinationFolderURL)
                    } else {
                        let fileDestinationURL = destinationFolderURL.appendingPathComponent(fileName)
                        self.downloadFile(file: file, to: fileDestinationURL)
                    }
                }
            } catch {
                print("Failed to parse response: \(error)")
            }
        }
        task.resume()
    }
}

extension OneDriveManageViewController{
    @objc func goBack() {
        if stacks.count > 1 {
            stacks.removeLast()
        }
        loadFiles()
        if stacks.count == 1 {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    func goFolder(index:Int){
        if index >= 0 && index < stacks.count {
            stacks.removeSubrange((index + 1)..<stacks.count)
            loadFiles()
        }
    }
    
    func goNextFolder(id:String, name:String){
        stacks.append((path: "items/\(id)/children", name: name))
        loadFiles()
    }
    
    @objc func downloadSelectedFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        for file in selectedFiles {
            guard let keys = file.allKeys as? [String], let fileName = file["name"] as? String else{continue}
            if keys.contains(where: {$0 == "folder"}) {
                downloadFolder(folder: file, to: documentsURL)
            } else {
                let fileDestinationURL = documentsURL.appendingPathComponent(fileName)
                downloadFile(file: file, to: fileDestinationURL)
            }
        }
    }

    @objc func selectAllFiles() {
        if selectedFiles.count == dataArray.count {
            selectedFiles.removeAll()
        } else {
            selectedFiles = Set(dataArray)
        }
        tableView.reloadData()
    }
}

extension OneDriveManageViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomFileCell", for: indexPath) as! CustomFileCell
        let file = dataArray[indexPath.row]
        
        // 设置图标，标题和小标题
        cell.titleLabel.text = file["name"] as? String
        if file.allKeys.contains(where: {($0 as! String) == "folder"}) {
            cell.iconImageView.image = UIImage(named: "folder_icon")
            let folder = file["folder"] as? NSDictionary
            cell.subtitleLabel.text = "\(folder?["childCount"] ?? 0)项"
        } else {
            cell.iconImageView.image = UIImage(named: "file_icon")
            if let size = file["size"] as? Int64, let modifyDateTime = file["lastModifiedDateTime"] as? Date {
                let fileSize = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                let modifiedDate = dateFormatter.string(from: modifyDateTime)
                cell.subtitleLabel.text = "\(fileSize) | \(modifiedDate)"
            }
        }
        
        // 设置选中按钮
        let imageName = selectedFiles.contains(file) ? "checkbox_1" : "checkbox_0"
        cell.checkboxImageView.setImage(UIImage(named: imageName), for: .normal)
        cell.checkClosure = { [weak self] in
            guard let self = self else { return }
            if self.selectedFiles.contains(file) {
                self.selectedFiles.remove(file)
            } else {
                self.selectedFiles.insert(file)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = dataArray[indexPath.row]
        if file.allKeys.contains(where: {($0 as! String) == "folder"}) {
            guard let fileId = file["id"] as? String,let fileName = file["name"] as? String else{return}
            goNextFolder(id: fileId, name: fileName)
        } else {
            if selectedFiles.contains(file) {
                selectedFiles.remove(file)
            } else {
                selectedFiles.insert(file)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
