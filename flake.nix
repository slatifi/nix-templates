{
    description = "All of my template flakes to build various projects";

    outputs = { self }: {
        templates = {
            latex = {
                path = ./latex;
                description = "Latex Document Builder";
            };
        };
    };
}
