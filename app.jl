using Clustering
import RDatasets: dataset
import DataFrames

using GenieFramework
@genietools

const data = DataFrames.insertcols!(dataset("datasets", "iris"), :Cluster => zeros(Int, 150))
features = [:SepalLength, :SepalWidth, :PetalLength, :PetalWidth]

function cluster(no_of_clusters=3, no_of_iterations=10)
    feats = Matrix(data[:, [c for c in features]])' |> collect
    result = kmeans(feats, no_of_clusters; maxiter=no_of_iterations)
    data[!, :Cluster] = assignments(result)
end

@handlers begin
    @out features
    @in no_of_clusters = 3
    @in no_of_iterations = 10
    @in xfeature = :SepalLength
    @in yfeature = :SepalWidth
    @out datatable = DataTable()
    @out datatablepagination = DataTablePagination(rows_per_page=50)
    @out irisplot = PlotData[]
    @out clusterplot = PlotData[]

    @onchange isready, xfeature, yfeature, no_of_clusters, no_of_iterations begin
        cluster(no_of_clusters, no_of_iterations)
        datatable = DataTable(data)
        irisplot = plotdata(data, xfeature, yfeature; groupfeature=:Species)
        clusterplot = plotdata(data, xfeature, yfeature; groupfeature=:Cluster)
    end
end

@page("/", "app.jl.html")
