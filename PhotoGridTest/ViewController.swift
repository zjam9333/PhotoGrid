//
//  ViewController.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/13.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UICollectionViewDelegate {
    var collectionView: UICollectionView!
    
    var compositionalLayout: UICollectionViewCompositionalLayout!
    var diffDataSource: UICollectionViewDiffableDataSource<Int, CollectionViewCell.Model>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Grid List"
        
        let item: NSCollectionLayoutItem = .init(layoutSize: .init(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1)))
        let group: NSCollectionLayoutGroup = .horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.3)), subitems: [item])
        group.interItemSpacing = .fixed(10)
        group.edgeSpacing = .init(leading: .fixed(10), top: .fixed(0), trailing: .fixed(0), bottom: .fixed(10))
        compositionalLayout = UICollectionViewCompositionalLayout(section: .init(group: group))
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        diffDataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            cell.model = itemIdentifier
            return cell
        }
        
        collectionView.dataSource = diffDataSource
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        var snap = diffDataSource.snapshot()
        snap.appendSections([0])
        snap.appendItems([
            .init(originalJson: json0),
            .init(originalJson: json1),
            .init(originalJson: json2),
            .init(originalJson: json3),
            .init(originalJson: json4),
            .init(originalJson: json),
            .init(originalJson: json),
        ])
        diffDataSource.apply(snap)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "griddetail") as! GridViewController
        let model = diffDataSource.snapshot(for: indexPath.section).items[indexPath.item]
        // 复制一份全新的
        detail.gridJson = GridJson.fromJson(model.gridJson.toJson())
        navigationController?.pushViewController(detail, animated: true)
    }
}

let json0: String = """
{
    "width": 300,
    "height": 300,
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

let json: String = """
{
    "width": 300,
    "height": 300,
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
