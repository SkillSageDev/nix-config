{ pkgs }:

let
  # Combine NLTK datasets into a single directory tree
  nltk-data = pkgs.symlinkJoin {
    name = "nltk-data";
    paths = [
      pkgs.nltk-data.stopwords

      # Add more corpora here if you need them later, e.g.:
      # pkgs.nltk-data.punkt
      # pkgs.nltk-data.wordnet
    ];
  };
in
pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.nltk
      python-pkgs.scikit-learn
      python-pkgs.requests
    ]))
  ];

  # Explicitly tell NLTK where to find the dataset(s) in the shell
  NLTK_DATA = "${nltk-data}/share/nltk_data";
}
