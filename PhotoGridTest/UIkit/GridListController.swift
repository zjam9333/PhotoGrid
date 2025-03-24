//
//  GridListController.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/13.
//

import UIKit
import SnapKit
import PhotosUI

class GridListController: UIViewController {
    var collectionView: UICollectionView!
    
    var compositionalLayout: UICollectionViewCompositionalLayout!
    var diffDataSource: UICollectionViewDiffableDataSource<Int, CollectionViewCell.Model>!
    
    var selectedImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewImages))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadAll))
        
        self.navigationItem.title = "Grid List"
        
        let item: NSCollectionLayoutItem = .init(layoutSize: .init(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1)))
        let group: NSCollectionLayoutGroup = .horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.3)), subitems: [item])
        group.interItemSpacing = .fixed(10)
        group.edgeSpacing = .init(leading: .fixed(10), top: .fixed(0), trailing: .fixed(0), bottom: .fixed(10))
        let section: NSCollectionLayoutSection = .init(group: group)
        section.contentInsets = .init(top: 10, leading: 0, bottom: 0, trailing: 0)
        
        compositionalLayout = UICollectionViewCompositionalLayout(section: section)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        diffDataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            cell.model = itemIdentifier
            cell.redView.contentGetter = { [weak self] key in
                if self?.selectedImages.indices.contains(key) == true {
                    return self?.selectedImages[key]
                }
                return nil
            }
            cell.redView.refreshSubviewsContent()
            return cell
        }
        
        collectionView.dataSource = diffDataSource
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        reloadAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for i in collectionView.visibleCells {
            if let cell = i as? CollectionViewCell {
                cell.redView.refreshSubviewsFrame()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = diffDataSource.itemIdentifier(for: indexPath)!
        let detail = GridViewController(gridJson: model.gridJson, selectedImages: selectedImages)
        navigationController?.pushViewController(detail, animated: true)
    }
    
    @objc func addNewImages() {
        pickImageUsePHPicker()
    }
    
    @objc func reloadAll() {
        selectedImages.removeAll()
        
        var snap = diffDataSource.snapshot()
        snap.deleteAllItems()
        snap.appendSections([0])
        let gridJsons: [CollectionViewCell.Model] = [
            .init(originalJson: jsonOnlyOne),
            .init(originalJson: json0),
            .init(originalJson: json1),
            .init(originalJson: json2),
            .init(originalJson: json3),
            .init(originalJson: json4),
            .init(originalJson: json5),
            .init(originalJson: json),
        ]
            
        gridJsons.forEach { model in
            // 试一试缩放
            model.gridJson = model.gridJson.scaled(toSize: .init(width: view.frame.width - 2, height: view.frame.width - 2))
        }
        snap.appendItems(gridJsons)
        diffDataSource.apply(snap)
    }
    
    private func pickImageUsePHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 4
        configuration.filter = .images // 仅允许选择图片
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    private func pickImageUseImagePickController() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true)
        }
    }
}
extension GridListController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        var idx = 0
        var total = results.count
        let group = DispatchGroup()
        for result in results {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                defer {
                    group.leave()
                }
                guard let this = self else { return }
                if let error = error {
                    total -= 1
                    print("加载图片出错: \(error.localizedDescription)")
                    return
                }
                if let image = image as? UIImage {
                    idx += 1
                    this.selectedImages.append(image)
                    print(idx, total)
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            for i in self?.collectionView.visibleCells ?? [] {
                if let cell = i as? CollectionViewCell {
                    cell.redView.refreshSubviewsContent()
                }
            }
        }
    }
}

extension GridListController: UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 实现 UIImagePickerControllerDelegate 协议方法，处理用户选择图片的操作
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.originalImage] as? UIImage {
            selectedImages.append(img)
            collectionView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 实现 UIImagePickerControllerDelegate 协议方法，处理用户取消选择的操作
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

let jsonOnlyOne: String = """
{
    "width": 300,
    "height": 300,
    "borderWidth": 10,
    "item": {
        "type": "polygon",
        "key": 0
    }
}
"""

let json0: String = """
{
    "width": 300,
    "height": 300,
    "borderWidth": 10,
    "lineWidth": 10,
    "item": {
        "type": "line",
        "key": 0,
        "line": {
            "x1": 0,
            "y1": 150,
            "x2": 300,
            "y2": 150
        },
        "offset": {
            "dx": 0,
            "dy": 0
        },
        "left": {
            "type": "polygon",
            "key": 0,
            "controllableKeys": [
                0
            ]
        },
        "right": {
            "type": "polygon",
            "key": 1,
            "controllableKeys": [
                0
            ]
        }
    }
}
"""

let json1: String = """
{
    "width": 300,
    "height": 300,
    "borderWidth": 10,
    "lineWidth": 10,
    "item": {
        "type": "line",
        "key": 0,
        "line": {
            "x1": 0,
            "y1": 150,
            "x2": 300,
            "y2": 150
        },
        "offset": {
            "dx": 0,
            "dy": 0
        },
        "left": {
            "type": "polygon",
            "key": 0,
            "controllableKeys": [
                0
            ]
        },
        "right": {
            "type": "line",
            "key": 1,
            "line": {
                "x1": 150,
                "y1": 0,
                "x2": 150,
                "y2": 300
            },
            "offset": {
                "dx": 0,
                "dy": 0
            },
            "left": {
                "type": "polygon",
                "key": 1,
                "controllableKeys": [
                    0,
                    1
                ]
            },
            "right": {
                "type": "polygon",
                "key": 2,
                "controllableKeys": [
                    0,
                    1
                ]
            }
        }
    }
}
"""

let json2: String = """
{
    "width": 300,
    "height": 300,
    "borderWidth": 10,
    "lineWidth": 10,
    "item": {
        "type": "line",
        "key": 0,
        "line": {
            "x1": 0,
            "y1": 100,
            "x2": 300,
            "y2": 100
        },
        "offset": {
            "dx": 0,
            "dy": 0
        },
        "left": {
            "type": "polygon",
            "key": 0,
            "controllableKeys": [
                0
            ]
        },
        "right": {
            "type": "line",
            "key": 1,
            "line": {
                "x1": 0,
                "y1": 200,
                "x2": 300,
                "y2": 200
            },
            "offset": {
                "dx": 0,
                "dy": 0
            },
            "left": {
                "type": "polygon",
                "key": 1,
                "controllableKeys": [
                    0,
                    1
                ]
            },
            "right": {
                "type": "polygon",
                "key": 2,
                "controllableKeys": [
                    1
                ]
            }
        }
    }
}
"""

let json3: String = """
{
    "width": 300,
    "height": 300,
    "borderWidth": 10,
    "lineWidth": 10,
    "item": {
        "type": "line",
        "key": 0,
        "line": {
            "x1": 0,
            "y1": 150,
            "x2": 300,
            "y2": 150
        },
        "offset": {
            "dx": 0,
            "dy": 0
        },
        "left": {
            "type": "line",
            "key": 1,
            "line": {
                "x1": 150,
                "y1": 0,
                "x2": 150,
                "y2": 300
            },
            "offset": {
                "dx": 0,
                "dy": 0
            },
            "syncGroup": [
                1,
                2
            ],
            "left": {
                "type": "polygon",
                "key": 0,
                "controllableKeys": [
                    0,
                    1
                ]
            },
            "right": {
                "type": "polygon",
                "key": 1,
                "controllableKeys": [
                    0,
                    1
                ]
            }
        },
        "right": {
            "type": "line",
            "key": 2,
            "line": {
                "x1": 150,
                "y1": 0,
                "x2": 150,
                "y2": 300
            },
            "offset": {
                "dx": 0,
                "dy": 0
            },
            "syncGroup": [
                1,
                2
            ],
            "left": {
                "type": "polygon",
                "key": 2,
                "controllableKeys": [
                    2,
                    0
                ]
            },
            "right": {
                "type": "polygon",
                "key": 3,
                "controllableKeys": [
                    2,
                    0
                ]
            }
        }
    }
}
"""

let json4: String = """
{
    "width": 300,
    "height": 300,
    "borderWidth": 10,
    "lineWidth": 10,
    "item": {
        "type": "line",
        "key": 0,
        "line": {
            "x1": 0,
            "y1": 150,
            "x2": 300,
            "y2": 150
        },
        "offset": {
            "dx": 0,
            "dy": 0
        },
        "left": {
            "type": "line",
            "key": 1,
            "line": {
                "x1": 150,
                "y1": 0,
                "x2": 150,
                "y2": 300
            },
            "offset": {
                "dx": 50,
                "dy": 0
            },
            "left": {
                "type": "polygon",
                "key": 0,
                "controllableKeys": [
                    0,
                    1
                ]
            },
            "right": {
                "type": "polygon",
                "key": 1,
                "controllableKeys": [
                    0,
                    1
                ]
            }
        },
        "right": {
            "type": "line",
            "key": 2,
            "line": {
                "x1": 150,
                "y1": 0,
                "x2": 150,
                "y2": 300
            },
            "offset": {
                "dx": -50,
                "dy": 0
            },
            "left": {
                "type": "polygon",
                "key": 2,
                "controllableKeys": [
                    2,
                    0
                ]
            },
            "right": {
                "type": "polygon",
                "key": 3,
                "controllableKeys": [
                    2,
                    0
                ]
            }
        }
    }
}
"""

let json5 = """
{
    "width": 300,
    "height": 300,
    "borderWidth": 10,
    "lineWidth": 10,
    "cornerRadius": 0,
    "item": {
        "type": "line",
        "key": 0,
        "line": {
            "x1": 0,
            "y1": 180,
            "x2": 300,
            "y2": 120
        },
        "offset": {
            "dx": 0,
            "dy": 0
        },
        "left": {
            "type": "line",
            "key": 1,
            "line": {
                "x1": 150,
                "y1": 0,
                "x2": 180,
                "y2": 300
            },
            "offset": {
                "dx": 0,
                "dy": 0
            },
            "syncGroup": [
                1,
                2
            ],
            "left": {
                "type": "polygon",
                "key": 0,
                "controllableKeys": [
                    0,
                    1
                ]
            },
            "right": {
                "type": "polygon",
                "key": 1,
                "controllableKeys": [
                    0,
                    1
                ]
            }
        },
        "right": {
            "type": "line",
            "key": 2,
            "line": {
                "x1": 150,
                "y1": 0,
                "x2": 180,
                "y2": 300
            },
            "offset": {
                "dx": 0,
                "dy": 0
            },
            "syncGroup": [
                1,
                2
            ],
            "left": {
                "type": "polygon",
                "key": 2,
                "controllableKeys": [
                    2,
                    0
                ]
            },
            "right": {
                "type": "polygon",
                "key": 3,
                "controllableKeys": [
                    2,
                    0
                ]
            }
        }
    }
}
"""

let json: String = """
{
    "width": 300,
    "height": 300,
    "borderWidth": 10,
    "lineWidth": 10,
    "cornerRadius": 0,
    "item": {
        "type": "line",
        "key": 0,
        "line": {
            "x1": 0,
            "y1": 100,
            "x2": 300,
            "y2": 80
        },
        "offset": {
            "dx": 30,
            "dy": 30
        },
        "left": {
            "type": "polygon",
            "key": 0,
            "controllableKeys": [
                0
            ]
        },
        "right": {
            "type": "line",
            "key": 1,
            "line": {
                "x2": 160,
                "y2": 0,
                "x1": 100,
                "y1": 300
            },
            "left": {
                "type": "polygon",
                "key": 1,
                "controllableKeys": [
                    0,
                    1
                ]
            },
            "right": {
                "type": "line",
                "key": 2,
                "line": {
                    "x1": 0,
                    "y1": 200,
                    "x2": 300,
                    "y2": 230
                },
                "left": {
                    "type": "polygon",
                    "key": 2,
                    "controllableKeys": [
                        0,
                        1,
                        2
                    ]
                },
                "right": {
                    "type": "polygon",
                    "key": 3,
                    "controllableKeys": [
                        1,
                        2
                    ]
                }
            }
        }
    }
}
"""
